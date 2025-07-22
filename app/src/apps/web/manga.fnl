(local {: assert} (require :page))
(local Mangas (require :models.mangas))
(local UserFavs (require :models.user_favs))
(local Users (require :models.users))
(local CartItems (require :models.cart_items))

[{:name "manga"
  :path "/manga/:id"
  :actions {:GET (fn [self]
                   (assert self.params.id)
                   (set self.manga (Mangas:get self.params.id))
                   (self:set_title self.manga.name)
                   (set self.mark_fav false)
                   (when self.session.user
                     (let [username self.session.user.username
                           user (assert (Users:get username))
                           cart (user:get_user_Cart)
                           is-fav? (UserFavs:find_favorite (user.id self.params.id))
                           item (CartItems:find {:user_cart_id cart.id
                                                 :manga_id self.manga.id})]
                       (when is-fav?
                         (set self.mark_fav true))
                       (when item
                         (set self.manga.stock
                              (- self.manga.stock item.quantity)))))
                   (self:render "web.manga"))}}]
