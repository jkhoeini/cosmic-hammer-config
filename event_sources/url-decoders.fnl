
;; event_sources/url-decoders.fnl
;; URL decoder pipeline: ordered list of decoders that unwrap redirect URLs.
;;
;; Each decoder: {:name :decoder-name
;;               :match {:scheme :https :host "*.example.com" :path "/*"}
;;               :decode-fn (fn [ctx] decoded-url-or-nil)}
;;
;; Decoder ctx is {:url current-url :parts (hs.http.urlParts current-url)}
;; nil return means no transform; a returned string replaces the current URL.
;; Pipeline runs until stable or :decoder-max-depth (default 5).

(local {: string?} (require :lib.cljlib-shim))


;; ============================================================================
;; Wildcard Matching
;; ============================================================================

(fn escape-lua-pattern [s]
  "Escape Lua pattern magic characters in a string."
  (string.gsub s "[%(%)%.%%%+%-%*%?%[%]%^%$]" "%%%1"))


(fn wildcard-to-pattern [wildcard]
  "Convert a wildcard string (with * globs) to a Lua pattern.
   * matches zero or more characters. Anchored with ^ and $."
  ;; First escape everything, then replace the escaped %* with (.*)
  (let [escaped (escape-lua-pattern wildcard)
        pattern (string.gsub escaped "%%%*" "(.*)")]
    (.. "^" pattern "$")))


(fn wildcard-match? [value wildcard]
  "Check if value matches a wildcard pattern. Case-insensitive for hosts."
  (when (and value wildcard)
    (let [pattern (wildcard-to-pattern wildcard)]
      (not= nil (string.match (string.lower value) (string.lower pattern))))))


;; ============================================================================
;; Decoder Matching
;; ============================================================================

(fn field-matches? [url-value pattern]
  "Check if a URL field matches a pattern. nil pattern means match any."
  (if (= nil pattern) true
      (= nil url-value) false
      (wildcard-match? url-value pattern)))


(fn decoder-matches? [decoder parts]
  "Check if a decoder's :match fields all match the given URL parts."
  (let [match-spec (or decoder.match {})]
    (and (field-matches? parts.scheme match-spec.scheme)
         (field-matches? parts.host match-spec.host)
         (field-matches? parts.path match-spec.path))))


;; ============================================================================
;; Decoder Pipeline
;; ============================================================================

(fn parse-url-parts [url]
  "Safely parse URL parts via hs.http.urlParts. Returns parts table or nil."
  (let [(ok parts) (pcall hs.http.urlParts url)]
    (when ok parts)))


(fn valid-decode-result? [result original-url]
  "Check that a decode-fn result is a valid non-empty string different from the input."
  (and (string? result)
       (> (length result) 0)
       (not= result original-url)))


(fn run-decoders [decoders max-depth url]
  "Run the decoder pipeline on a URL.
   Returns the final decoded URL (possibly unchanged).
   decoders: ordered list of decoder specs
   max-depth: max iterations (default 5)
   url: the initial URL string"
  (let [max-depth (or max-depth 5)]
    (var current-url url)
    (var seen {})
    (tset seen url true)
    (var iteration 0)
    (var done false)
    (while (and (not done) (< iteration max-depth))
      (set iteration (+ iteration 1))
      (let [parts (parse-url-parts current-url)]
        (if (= nil parts)
            ;; Cannot parse URL; stop
            (set done true)
            ;; Try each decoder in order
            (do
              (var changed false)
              (each [_ decoder (ipairs decoders)]
                (when (and (not changed) (decoder-matches? decoder parts))
                  (let [(ok result) (pcall decoder.decode-fn
                                           {:url current-url :parts parts})]
                    (when (and ok (valid-decode-result? result current-url))
                      (if (. seen result)
                          ;; Loop detected — stop with current URL
                          (do
                            (print (.. "[WARN] url-decoders: loop detected, stopping at: "
                                       current-url))
                            (set done true))
                          (do
                            (tset seen result true)
                            (set current-url result)
                            (set changed true))))
                    (when (not ok)
                      (print (.. "[WARN] url-decoders: decoder '"
                                 (tostring decoder.name) "' failed: "
                                 (tostring result)))))))
              (when (not changed)
                (set done true))))))
    current-url))


;; ============================================================================
;; Built-in Decoders
;; ============================================================================

(local slack-redir-decoder
  {:name :slack-redir
   :match {:host "*.slack-redir.net"}
   :decode-fn (fn [ctx]
                (when ctx.parts.queryItems
                  (var target nil)
                  (each [_ item (ipairs ctx.parts.queryItems)]
                    (when (and (not target) item.name (= item.name :url))
                      (set target item.value)))
                  target))})


(local outlook-safelinks-decoder
  {:name :outlook-safelinks
   :match {:host "safelinks.protection.outlook.com"}
   :decode-fn (fn [ctx]
                (when ctx.parts.queryItems
                  (var target nil)
                  (each [_ item (ipairs ctx.parts.queryItems)]
                    (when (and (not target) item.name (= item.name :url))
                      (set target item.value)))
                  target))})


(local default-decoders [slack-redir-decoder outlook-safelinks-decoder])


{: run-decoders
 : default-decoders
 : wildcard-match?
 : decoder-matches?
 : parse-url-parts}
