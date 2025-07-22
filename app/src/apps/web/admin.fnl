(local Users (require :models.users))
(local Mangas (require :models.mangas))
(local Sales (require :models.sales))
(local Tags (require :models.tags))

(fn retrieve-stats []
  (let [sales (Sales:count)]
    {:user_count (Users:count)
     :admin_count (Users:count "is_admin")
     :prod_count (Mangas:count)
     :tag_count (Tags:count)
     :sales (if (= sales 0) "0 :(" sales)}))

[{:name "admin.index"
  :path "/admin"
  :actions {:before (fn [self]
                      (if (not self.session.user)
                          (self:redirect_to "web.user.login")))
            :GET (fn [self]
                   (set self.stats (retrieve-stats))
                   (self:render "web.admin.index"))}}
 {:name "admin.manga"
  :path "/admin/manga"
  :actions {:GET (fn [self]
                   (self:render "web.admin.manga"))}}
 {:name "admin.users"
  :path "/admin/users"
  :actions {:GET (fn [self]
                   (self:render "web.admin.users"))}}]
