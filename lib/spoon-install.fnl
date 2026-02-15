;; spoon-install.fnl
;; Adapted from SpoonInstall.spoon by Diego Zamboni (MIT license)
;; Original: https://github.com/Hammerspoon/Spoons
;;
;; Installs and manages Hammerspoon Spoons from GitHub repositories.

(local logger (hs.logger.new :spoon-install))

(local repos
       {:default {:branch :master
                  :desc "Main Hammerspoon Spoon repository"
                  :url "https://github.com/Hammerspoon/Spoons"}})

(local use-syncinstall false)

;; ============================================================================
;; Private helpers
;; ============================================================================

(fn exec! [cmd errfmt ...]
  "Execute a shell command, return trimmed output or nil on failure."
  (let [(output status) (hs.execute cmd)]
    (if status
        (let [trimstr (string.gsub output "\n*$" "")] trimstr)
        (do
          (logger.ef errfmt ...) nil))))

;; ============================================================================
;; Repository management (private)
;; ============================================================================

(fn store-repo-json! [repo callback status body hdrs]
  "Process and store docs.json data for a repository."
  (var success nil)
  (if (or (< status 100) (>= status 400))
      (logger.ef "Error fetching JSON data for repository '%s'. Error code %d: %s"
                  repo status (or body "<no error message>"))
      (let [json (hs.json.decode body)]
        (if json
            (do
              (tset (. repos repo) :data {})
              (each [i v (ipairs json)]
                (set v.download_url
                     (.. (. repos repo :download_base_url) v.name
                         :.spoon.zip))
                (tset (. repos repo :data) v.name v))
              (logger.df "Updated JSON data for repository '%s'" repo)
              (set success true))
            (logger.ef "Invalid JSON received for repository '%s': %s"
                        repo body))))
  (when callback (callback repo success))
  success)

(fn build-repo-json-url! [repo]
  "Build the JSON metadata and download URLs for a repository."
  (if (and (. repos repo) (. repos repo :url))
      (let [branch (or (. repos repo :branch) :master)]
        (tset (. repos repo) :json_url
              (.. (string.gsub (. repos repo :url) "/$" "") :/raw/ branch
                  :/docs/docs.json))
        (tset (. repos repo) :download_base_url
              (.. (string.gsub (. repos repo :url) "/$" "") :/raw/ branch
                  :/Spoons/))
        true)
      (do
        (logger.ef "Invalid or unknown repository '%s'" repo)
        nil)))

;; ============================================================================
;; Repository management (public)
;; ============================================================================

(fn async-update-repo! [repo callback]
  "Asynchronously fetch repository contents. Defaults to 'default' repo."
  (let [repo (or repo :default)]
    (if (build-repo-json-url! repo)
        (do
          (hs.http.asyncGet (. repos repo :json_url) nil
                            (fn [status body hdrs]
                              (store-repo-json! repo callback status body hdrs)))
          true)
        nil)))

(fn update-repo! [repo]
  "Synchronously fetch repository contents. Blocks Hammerspoon."
  (let [repo (or repo :default)]
    (if (build-repo-json-url! repo)
        (let [(a b c) (hs.http.get (. repos repo :json_url))]
          (store-repo-json! repo nil a b c))
        nil)))

(fn async-update-all-repos! []
  "Asynchronously fetch contents of all registered repositories."
  (each [k v (pairs repos)] (async-update-repo! k)))

(fn update-all-repos! []
  "Synchronously fetch contents of all registered repositories."
  (each [k v (pairs repos)] (update-repo! k)))

(fn add-repo! [name config]
  "Register a new Spoon repository."
  (tset repos name config))

(fn repo-list []
  "Return a sorted list of registered repository identifiers."
  (let [keys {}]
    (each [k v (pairs repos)] (table.insert keys k))
    (table.sort keys)
    keys))

(fn search [pat]
  "Search repositories for a Lua pattern against name and description."
  (let [res {}]
    (each [repo v (pairs repos)]
      (if v.data
          (each [spoon rec (pairs v.data)]
            (when (string.find (string.lower (.. rec.name "\n" rec.desc)) pat)
              (table.insert res {:desc rec.desc :name rec.name : repo})))
          (logger.ef "Repository data for '%s' not available - call (update-repo! \"%s\"), then try again."
                      repo repo)))
    res))

;; ============================================================================
;; Spoon installation (private)
;; ============================================================================

(fn install-spoon-from-zip-url-callback! [urlparts callback status body headers]
  "Callback to finalize Spoon installation after zip download."
  (var success nil)
  (if (or (< status 100) (>= status 400))
      (logger.ef "Error downloading %s. Error code %d: %s"
                  urlparts.absoluteString status (or body :<none>))
      (let [tmpdir (exec! "/usr/bin/mktemp -d"
                          "Error creating temporary directory to download new spoon.")]
        (when tmpdir
          (local outfile
                 (string.format "%s/%s" tmpdir urlparts.lastPathComponent))
          (local f (assert (io.open outfile :w)))
          (f:write body)
          (f:close)
          (local output (exec! (string.format "/usr/bin/unzip -l %s '*.spoon/' | /usr/bin/awk '$NF ~ /\\.spoon\\/$/ { print $NF }' | /usr/bin/wc -l"
                                              outfile)
                               "Error examining downloaded zip file %s, leaving it in place for your examination."
                               outfile))
          (when output
            (if (= (or (tonumber output) 0) 1)
                (let [outdir (string.format "%s/Spoons" hs.configdir)]
                  (when (exec! (string.format "/usr/bin/unzip -o %s -d %s 2>&1"
                                              outfile outdir)
                               "Error uncompressing file %s, leaving it in place for your examination."
                               outfile)
                    (logger.f "Downloaded and installed %s"
                              urlparts.absoluteString)
                    (exec! (string.format "/bin/rm -rf '%s'" tmpdir)
                           "Error removing directory %s" tmpdir)
                    (set success true)))
                (logger.ef "The downloaded zip file %s is invalid - it should contain exactly one spoon. Leaving it in place for your examination."
                            outfile))))))
  (when callback (callback urlparts success))
  success)

(fn valid-spoon? [name repo]
  "Check if a Spoon/Repo combination is valid."
  (if (. repos repo)
      (if (. repos repo :data)
          (if (. repos repo :data name) true
              (logger.ef "Spoon '%s' does not exist in repository '%s'. Please check and try again."
                          name repo))
          (logger.ef "Repository data for '%s' not available - call (update-repo! \"%s\"), then try again."
                      repo repo))
      (logger.ef "Invalid or unknown repository '%s'" repo)))

;; ============================================================================
;; Spoon installation (public)
;; ============================================================================

(fn async-install-spoon-from-zip-url! [url callback]
  "Asynchronously download and install a Spoon from a zip URL."
  (let [urlparts (hs.http.urlParts url)
        dlfile urlparts.lastPathComponent]
    (if (and (and dlfile (not= dlfile "")) (= urlparts.pathExtension :zip))
        (do
          (hs.http.asyncGet url nil
                            (fn [status body headers]
                              (install-spoon-from-zip-url-callback! urlparts callback status body headers)))
          true)
        (do
          (logger.ef "Invalid URL %s, must point to a zip file" url)
          nil))))

(fn install-spoon-from-zip-url! [url]
  "Synchronously download and install a Spoon from a zip URL."
  (let [urlparts (hs.http.urlParts url)
        dlfile urlparts.lastPathComponent]
    (if (and (and dlfile (not= dlfile "")) (= urlparts.pathExtension :zip))
        (do
          (local (a b c) (hs.http.get url))
          (install-spoon-from-zip-url-callback! urlparts nil a b c))
        (do
          (logger.ef "Invalid URL %s, must point to a zip file" url)
          nil))))

(fn async-install-spoon-from-repo! [name repo callback]
  "Asynchronously install a Spoon from a registered repository."
  (let [repo (or repo :default)]
    (when (valid-spoon? name repo)
      (async-install-spoon-from-zip-url! (. repos repo :data name
                                             :download_url)
                                          callback))
    nil))

(fn install-spoon-from-repo! [name repo]
  "Synchronously install a Spoon from a registered repository."
  (let [repo (or repo :default)]
    (if (valid-spoon? name repo)
        (install-spoon-from-zip-url! (. repos repo :data name
                                                    :download_url))
        nil)))

(fn and-use! [name arg]
  "Declaratively install, load and configure a Spoon.
  Accepts optional arg table with keys:
    :repo :config :hotkeys :fn :loglevel :start :disable"
  (let [arg (or arg {})]
    (if arg.disable
        true
        (hs.spoons.use name arg true)
        true
        (let [repo (or arg.repo :default)]
          (if (. repos repo)
              (if (. repos repo :data)
                  (do
                    (fn load-and-config [_ success]
                      (if success
                          (do
                            (hs.notify.show "Spoon installed"
                                            (.. name ".spoon is now available") "")
                            (hs.spoons.use name arg))
                          (logger.ef "Error installing Spoon '%s' from repo '%s'"
                                     name repo)))
                    (if use-syncinstall
                        (load-and-config nil (install-spoon-from-repo! name repo))
                        (async-install-spoon-from-repo! name repo load-and-config)))
                  (do
                    (fn update-repo-and-continue [_ success]
                      (if success (and-use! name arg)
                          (logger.ef "Error updating repository '%s'" repo)))
                    (if use-syncinstall
                        (update-repo-and-continue nil (update-repo! repo))
                        (async-update-repo! repo update-repo-and-continue))))
              (logger.ef "Unknown repository '%s' for Spoon" repo name))))))

;; ============================================================================
;; Public API
;; ============================================================================

{: and-use!
 : add-repo!
 : search
 : repo-list
 : update-repo!
 : async-update-repo!
 : update-all-repos!
 : async-update-all-repos!
 : install-spoon-from-zip-url!
 : async-install-spoon-from-zip-url!
 : install-spoon-from-repo!
 : async-install-spoon-from-repo!}
