
;; lib/url-routing.fnl
;; Pure helper functions for URL routing: browser resolution, URL matching,
;; and rule evaluation. No registry dependencies.

(local {: some : seq : empty?} (require :lib.cljlib-shim))


;; ============================================================================
;; Browser Resolution
;; ============================================================================

(fn build-browser-lookup [browsers]
  "Build a lookup table from a browsers list by :id.
   Input:  [{:id :safari :bundle-id \"com.apple.Safari\"} ...]
   Output: {:safari {:id :safari :bundle-id \"com.apple.Safari\"} ...}"
  (let [lookup {}]
    (each [_ browser (ipairs (or browsers []))]
      (when browser.id
        (tset lookup browser.id browser)))
    lookup))


(fn resolve-browser [browser-id lookup]
  "Resolve a browser-id to an enriched browser entry using HS APIs.
   Returns {:id :bundle-id :name :path :image} or nil if unresolvable.
   Warns and skips missing browser IDs or unresolved bundle IDs."
  (let [entry (. lookup browser-id)]
    (when (= nil entry)
      (print (.. "[WARN] resolve-browser: unknown browser-id '"
                 (tostring browser-id) "'"))
      (lua "return nil"))
    (let [bundle-id entry.bundle-id
          name (hs.application.nameForBundleID bundle-id)
          path (hs.application.pathForBundleID bundle-id)]
      (when (and (= nil name) (= nil path))
        (print (.. "[WARN] resolve-browser: bundle-id '"
                   (tostring bundle-id) "' not found on this system"))
        (lua "return nil"))
      (let [image (when hs.image
                    (hs.image.imageFromAppBundle bundle-id))]
        {:id entry.id
         :bundle-id bundle-id
         :name (or name (tostring bundle-id))
         :path path
         :image image}))))


(fn resolve-browsers [browser-ids lookup]
  "Resolve a list of browser-ids, skipping any that fail resolution.
   Returns a sequential table of resolved browser entries."
  (let [resolved []]
    (each [_ bid (ipairs browser-ids)]
      (let [browser (resolve-browser bid lookup)]
        (when browser
          (table.insert resolved browser))))
    resolved))


(fn make-chooser-choices [resolved-browsers]
  "Convert resolved browsers to hs.chooser choice format.
   Input:  [{:id :bundle-id :name :path :image} ...]
   Output: [{:text name :subText bundle-id :image image :bundle-id bundle-id} ...]"
  (let [choices []]
    (each [_ browser (ipairs resolved-browsers)]
      (table.insert choices {:text browser.name
                             :subText browser.bundle-id
                             :image browser.image
                             :bundle-id browser.bundle-id}))
    choices))


;; ============================================================================
;; URL Parsing
;; ============================================================================

(fn parse-url [url]
  "Parse a URL string into {:scheme :host :path}.
   Handles http(s)://host/path and scheme-only URLs (mailto:, file:, etc.).
   Strips query string and fragment from path. Normalizes host to lowercase."
  (when (= nil url)
    (lua "return {}"))
  ;; Try scheme://authority/path form first
  (let [scheme-end (url:find "://")
        result {}]
    (if scheme-end
        ;; Standard URL: scheme://host/path
        (let [scheme (url:sub 1 (- scheme-end 1))
              rest (url:sub (+ scheme-end 3))
              ;; Find authority end: first /, ?, or # after scheme://
              slash-pos (rest:find "/")
              qmark-pos (rest:find "%?")
              hash-pos (rest:find "#")
              ;; Authority ends at the earliest delimiter (or end of string)
              authority-end (let [candidates []]
                              (when slash-pos (table.insert candidates slash-pos))
                              (when qmark-pos (table.insert candidates qmark-pos))
                              (when hash-pos (table.insert candidates hash-pos))
                              (if (= 0 (length candidates))
                                  nil
                                  (math.min (unpack candidates))))
              host-part (if authority-end
                            (rest:sub 1 (- authority-end 1))
                            rest)
              ;; Everything from authority-end onwards is path+query+fragment
              rest-after-authority (if authority-end
                                      (rest:sub authority-end)
                                      "/")
              ;; Ensure path starts with / when authority ends at ? or #
              raw-path (if (and authority-end
                               (not= "/" (rest-after-authority:sub 1 1)))
                           (.. "/" rest-after-authority)
                           rest-after-authority)
              ;; Strip port from host
              port-sep (host-part:find ":")
              host (if port-sep
                       (host-part:sub 1 (- port-sep 1))
                       host-part)
              ;; Strip query and fragment from path
              query-pos (raw-path:find "%?")
              frag-pos (raw-path:find "#")
              path-end (if (and query-pos frag-pos) (math.min query-pos frag-pos)
                           query-pos query-pos
                           frag-pos frag-pos
                           nil)
              path (if path-end
                       (raw-path:sub 1 (- path-end 1))
                       raw-path)]
          (tset result :scheme (scheme:lower))
          (tset result :host (host:lower))
          (tset result :path path))
        ;; Non-standard URL: scheme:rest (e.g., mailto:user@host)
        (let [colon-pos (url:find ":")]
          (when colon-pos
            (let [raw-scheme (url:sub 1 (- colon-pos 1))]
              (tset result :scheme (raw-scheme:lower)))
            (let [rest (url:sub (+ colon-pos 1))]
              (tset result :path rest)))))
    result))


;; ============================================================================
;; URL Pattern Matching
;; ============================================================================

(fn escape-lua-pattern [str]
  "Escape Lua pattern metacharacters in a string.
   Necessary before converting wildcard syntax to Lua patterns."
  (str:gsub "([%(%)%.%%%+%-%[%]%^%$%?])" "%%%1"))


(fn match-scheme? [url-scheme pattern-scheme]
  "Match a URL scheme against a pattern. Pattern can be a string or list of strings.
   Missing pattern-scheme matches any."
  (when (= nil pattern-scheme)
    (lua "return true"))
  (when (= nil url-scheme)
    (lua "return false"))
  (if (= :string (type pattern-scheme))
      (= url-scheme (pattern-scheme:lower))
      ;; List of schemes: OR
      (do
        (var found false)
        (each [_ s (ipairs pattern-scheme)]
          (when (= url-scheme (s:lower))
            (set found true)))
        found)))


(fn match-host? [url-host pattern-host]
  "Match a URL host against a pattern.
   Supports exact match or leading wildcard (\"*.github.com\").
   Missing pattern-host matches any."
  (when (= nil pattern-host)
    (lua "return true"))
  (when (= nil url-host)
    (lua "return false"))
  (let [lower-pattern (pattern-host:lower)]
    (if (= "*." (lower-pattern:sub 1 2))
        ;; Wildcard subdomain: *.foo.com matches x.foo.com and foo.com
        (let [suffix (lower-pattern:sub 2)  ;; .foo.com
              escaped (escape-lua-pattern suffix)
              ;; Match: ends with .foo.com OR is exactly foo.com (without leading dot)
              bare-domain (lower-pattern:sub 3)]  ;; foo.com
          (or (not= nil (url-host:match (.. escaped "$")))
              (= url-host bare-domain)))
        ;; Exact match
        (= url-host lower-pattern))))


(fn match-path? [url-path pattern-path]
  "Match a URL path against a pattern with * wildcard support.
   * matches any sequence of characters. Missing pattern-path matches any."
  (when (= nil pattern-path)
    (lua "return true"))
  (when (= nil url-path)
    (lua "return false"))
  ;; Split pattern on *, escape each literal segment, join with .*
  (let [parts []]
    (var pos 1)
    (var i 1)
    (while (<= i (length pattern-path))
      (if (= "*" (pattern-path:sub i i))
          (do
            (table.insert parts (escape-lua-pattern (pattern-path:sub pos (- i 1))))
            (table.insert parts ".*")
            (set i (+ i 1))
            (set pos i))
          (set i (+ i 1))))
    ;; Final segment
    (table.insert parts (escape-lua-pattern (pattern-path:sub pos)))
    (let [full-pattern (.. "^" (table.concat parts) "$")]
      (not= nil (url-path:match full-pattern)))))


(fn match-url-pattern? [parsed-url url-pattern]
  "Match a parsed URL against a single URL pattern.
   A pattern is {:scheme :host :path} where missing fields match any.
   All present fields are ANDed."
  (and (match-scheme? parsed-url.scheme url-pattern.scheme)
       (match-host? parsed-url.host url-pattern.host)
       (match-path? parsed-url.path url-pattern.path)))


(fn match-urls? [parsed-url url-patterns]
  "Match a parsed URL against a list of URL patterns. Returns true on first match (OR).
   Missing or empty url-patterns matches nothing."
  (when (or (= nil url-patterns) (= 0 (length url-patterns)))
    (lua "return false"))
  (var matched false)
  (each [_ pattern (ipairs url-patterns)]
    (when (match-url-pattern? parsed-url pattern)
      (set matched true)))
  matched)


;; ============================================================================
;; Sender Matching
;; ============================================================================

(fn match-sender? [sender-bundle-id sender-bundle-ids]
  "Match a sender bundle ID against a list of allowed sender bundle IDs.
   Missing sender-bundle-ids matches any (no sender filter)."
  (when (= nil sender-bundle-ids)
    (lua "return true"))
  (when (= nil sender-bundle-id)
    (lua "return false"))
  (var found false)
  (each [_ bid (ipairs sender-bundle-ids)]
    (when (= sender-bundle-id bid)
      (set found true)))
  found)


;; ============================================================================
;; Rule Matching
;; ============================================================================

(fn match-rule? [parsed-url sender-bundle-id rule]
  "Match a parsed URL and sender against a single rule.
   A rule has a :match table with optional :urls and :sender-bundle-ids keys.
   Different :match keys are ANDed; multiple :urls entries are ORed."
  (let [match-spec rule.match]
    (when (= nil match-spec)
      ;; No match spec means rule matches everything
      (lua "return true"))
    (and (if match-spec.urls
             (match-urls? parsed-url match-spec.urls)
             true)
         (match-sender? sender-bundle-id match-spec.sender-bundle-ids))))


(fn find-matching-rule [parsed-url sender-bundle-id rules]
  "Find the first matching rule from an ordered list of rules.
   Returns the matched rule or nil if no rule matches."
  (var result nil)
  (each [_ rule (ipairs (or rules []))]
    (when (and (= nil result) (match-rule? parsed-url sender-bundle-id rule))
      (set result rule)))
  result)


;; ============================================================================
;; Exports
;; ============================================================================

{: build-browser-lookup
 : resolve-browser
 : resolve-browsers
 : make-chooser-choices
 : parse-url
 : escape-lua-pattern
 : match-scheme?
 : match-host?
 : match-path?
 : match-url-pattern?
 : match-urls?
 : match-sender?
 : match-rule?
 : find-matching-rule}
