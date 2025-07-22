(local {: conf : new-app} (require :page))
(local locale (require :locale))

(fn before-filter [self]
  (set self.site_name conf.site_name)
  (set self.page_title self.site_name)
  (set self.getstr (fn [_self name]
                     (locale.getstr name)))
  (set self.static_url "/static/%s")
  (set self.files_url "/files/%s/%s")
  (set self.set_title (fn [self text]
                        (->> (string.format "%s - %s" self.site_name text)
                             (set self.page_title))))
  (set self.format_url (fn [self pattern ...]
                         (-> (string.format pattern ...)
                             (self.build_url))))
  (set self.render (fn [_self name]
                     {:render name}))
  (set self.redirect_to
       (fn [self name]
         {:redirect_to (self:url_for name)})))

(new-app :web ["index" "search" "manga" "user" "admin"] before-filter)
