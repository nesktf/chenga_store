(local {: ngx : conf : new-base} (require :page))

(fn handle-404 [self]
  (let [api? (ngx.var.uri:match "^(/api).+$")]
    (if api?
        {:status 404 :json ["Resource not found!"]}
        (do
          (set self.page_title (.. conf.site_name " - 404"))
          {:render "code_404"}))))

(let [main-app (new-base)]
  (main-app:enable :etlua)
  (set main-app.layout (require :views.layout))
  (set main-app.handle_404 handle-404)
  (main-app:include :apps.ajax)
  (main-app:include :apps.api)
  (main-app:include :apps.web)
  main-app)
