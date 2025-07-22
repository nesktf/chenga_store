(local lapis (require :lapis))
(local lapis-app (require :lapis.application))
(local conf ((. (require :lapis.config) :get)))

(λ yield-err [msg ?err]
  (lapis-app.yield-err_error {:status (or ?err 1) : msg}))

(fn invalid-action [_self]
  {:render "code_404"})

(local action-mt {:GET invalid-action
                  :POST invalid-action
                  :PUT invalid-action
                  :DELETE invalid-action})

(set action-mt.__index action-mt)

(λ wrap-actions [actions]
  (let [action {:GET actions.GET
                :POST actions.POST
                :PUT actions.PUT
                :DELETE actions.DELETE
                :before actions.before}
        catch? (not= action.catch nil)]
    (setmetatable action action-mt)
    (if catch?
        (-> (lapis-app.respond_to action)
            (lapis-app.catch actions.catch))
        (lapis-app.respond_to action))))

(fn ajax-catch [_self]
  {:render :ajax.error})

(fn ajax-post [reqs]
  (fn [self]
    (when (not self.params.__ajax_frag)
      (yield-err "No fragment provided"))
    (let [func (. reqs self.params.__ajax_frag)]
      (when (not func)
        (-> (string.format "Fragment '%s' not found" self.params.__ajax_frag)
            (yield-err)))
      (func self))))

(local page-mt
       {:req (λ [self name path actions]
               "Create an action for simple HTML requests"
               (->> (wrap-actions actions)
                    (self._page:match name path)))
        :req-ajax (λ [self name path reqs]
                    (let [catch (or reqs.catch ajax-catch)]
                      (->> (wrap-actions {:POST (ajax-post reqs) : catch})
                           (self._page:match name path))))})

(set page-mt.__index page-mt)

(fn new-base []
  (let [app (lapis.Application)]
    (set app._base app)
    (set app.include
         (fn [self other-app]
           (let [pkg (if (= (type other-app) :string)
                         (require other-app)
                         other-app)
                 incl (if (not= pkg._page nil)
                          pkg._page
                          pkg)]
             (self.__class.include self incl nil self))))
    app))

(fn new-page [?base-name ?base-path ?before-filter]
  "Create a new lapis page, optionally runs ?before-filter before each action"
  "All children actions will have base-name and base-path as prefixes"
  (let [page (new-base)
        wrapper {:_page page}]
    (when ?before-filter
      (page:before_filter ?before-filter))
    (when ?base-name
      (set page.name (string.format "%s." ?base-name)))
    (set page.path ?base-path)
    (setmetatable wrapper page-mt)
    wrapper))

(λ new-app [name modules ?before-filter]
  (let [app (new-page nil nil ?before-filter)]
    (each [_i module-name (ipairs modules)]
      (let [pages (-> (string.format "apps.%s.%s" name module-name)
                      (require))]
        (each [_j {:name page-name :path page-path : actions : ajax?} (ipairs pages)]
          (assert (and page-name (not= page-name "")))
          (assert (and module-name (not= module-name "")))
          (let [sub-name (.. name "." page-name)]
            (if ajax?
                (app:req-ajax sub-name page-path actions)
                (app:req sub-name page-path actions))))))
    app))

{: new-base
 : new-page
 : new-app
 : wrap-actions
 : yield-err
 :ngx _G.ngx
 : conf
 :assert lapis-app.assert_error
 : lapis
 : lapis-app}
