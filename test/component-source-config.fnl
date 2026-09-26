(local {: make-hierarchy} (require :lib.hierarchy))
(local {: make-event-registry} (require :sheaf.event-registry))
(local {: make-source-registry : make-source-type : add-source-type!}
       (require :sheaf.source-registry))
(local {: make-trait-registry} (require :sheaf.trait-registry))
(local {: make-tag-registry} (require :sheaf.tag-registry))
(local {: make-component-registry : make-component-type : add-component-type!
        : start-component! : get-component-instance}
       (require :sheaf.component-registry))

(var captured nil)
(local hierarchy (make-hierarchy))
(local event-registry (make-event-registry {:hierarchy hierarchy}))
(local source-registry (make-source-registry {:event-registry event-registry}))
(local trait-registry (make-trait-registry {:hierarchy (make-hierarchy)}))
(local tag-registry (make-tag-registry))

(add-source-type! source-registry
  (make-source-type :event-source.type/probe "Probe"
                    {:start-fn (fn [self emit]
                                 (set captured self.config)
                                 self.config)}))

(local registry
  (make-component-registry {:hierarchy hierarchy
                            :trait-registry trait-registry
                            :source-registry source-registry
                            :tag-registry tag-registry}))

(add-component-type! registry
  (make-component-type
   :component.type/probe "Probe"
   {:start-fn (fn [config] {:value config.value})
    :sources [{:type :event-source.type/probe
               :instance-name "owned"
               :config-fn (fn [state config instance-name]
                            {:state state
                             :component-config config
                             :component-name instance-name})}]}))

(start-component! registry :component.type/probe
                  "component.probe.instance/main" {:value 42})
(local instance (get-component-instance registry "component.probe.instance/main"))

(assert (= 42 captured.state.value))
(assert (= 42 captured.component-config.value))
(assert (= "component.probe.instance/main" captured.component-name))
(assert (= captured
           (. source-registry.instances
              "component.probe.instance.main.event-source.probe.instance/owned"
              :state)))
(assert (= 42 instance.state.value))

(print "Component source config injection passed")
