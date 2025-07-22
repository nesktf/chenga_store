(local lapis (require :lapis))
(local lapis-app (require :lapis.application))

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
                :DELETE actions.DELETE}
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
        (-> (string.format "Fragment '%s' not found" self.params.__ajax_frag))
        (yield-err))
      (func self))))

(local page-mt
       {:req (λ [self name path actions]
               "Create an action for simple HTML requests"
               (->> (wrap-actions actions)
                    (self._page:match name path)))
        :ajax-req (λ [self name path reqs]
                    (let [catch (or reqs.catch ajax-catch)]
                      (->> (wrap-actions {:POST (ajax-post reqs) : catch})
                           (self._page:match name path))))
        :include (λ [self pkg]
                   (self._page.__class.include self pkg nil self))})

(set page-mt.__index page-mt)

(λ new-page [base-name base-path ?before-filter]
  "Create a new lapis page, optionally runs ?before-filter before each action"
  "All children actions will have base-name and base-path as prefixes"
  (let [page (lapis.Application)
        wrapper {:_page page}]
    (set page._base page)
    (when ?before-filter
      (page:before_filter ?before-filter))
    (set page.name (string.format "%s." base-name))
    (set page.path base-path)
    (setmetatable wrapper page-mt)
    wrapper))

(setmetatable {:new new-page : wrap-actions : yield-err}
              {:__call (fn [self ...]
                         (self.new ...))})
