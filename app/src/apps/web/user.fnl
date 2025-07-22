(local {: assert} (require :page))
(local Mangas (require :models.mangas))
(local Users (require :models.users))

(fn populate-cart-garbage! [self]
  (let [username self.session.user.username
        user (assert (Users:get username))
        cart (user:get_user_cart)
        cart-items (cart:get_cart_items)]
    (set self.user user)
    (set self.cart [])
    (var sum 0)
    (each [_i item (ipairs cart-items)]
      (let [manga (assert (Mangas:get item.manga_id))]
        (set sum (+ sum (* (/ manga.price 100) item.quantity)))
        (table.insert self.cart {:id item.id :quantity item.quantity : manga})))
    (->> (string.format "$%.2f" sum)
         (set self.cart_total))))

(fn login-user! [self]
  (let [params {:username self.params.username :password self.params.password}
        user (assert (Users:login params))]
    (set self.session.user {:username user.username :is_admin user.is_admin})
    (self:redirect_to "web.index")))

(fn register-user! [self]
  (let [params (assert (Users:validate {:name self.params.name
                                        :address self.params.address
                                        :email self.params.email
                                        :username self.params.username
                                        :password self.params.password
                                        :is_admin false}))
        user (assert (Users:new params))]
    (set self.session.user {:username user.username :is_admin user.is_admin})
    (self:redirect_to "web.index")))

(fn check-fucker [self]
  (if (not self.session.user)
      (self:redirect_to "web.user.login")))

[{:name "user.index"
  :path "/user"
  :actions {:GET (fn [self]
                   (if (not self.session.user)
                       (self:redirect_to "web.user.login")
                       (self:render "web.user.index")))}}
 {:name "user.login"
  :path "/user/login"
  :actions {:catch (fn [self]
                     (self:render "web.user.login"))
            :before (fn [self]
                      (if (not= self.params.logout nil)
                          (do
                            (set self.session.user nil)
                            (self:redirect_to "web.index"))
                          (not= self.session.user nil)
                          (self:redirect_to "web.index")
                          nil))
            :POST (fn [self]
                    (if (not= self.params.login nil) (login-user! self)
                        (not= self.params.register nil) (register-user! self)
                        (self:render "web.user.login")))
            :GET (fn [self]
                   (self:set_title "Login")
                   (self:render "web.user.login"))}}
 {:name "user.cart"
  :path "/user/cart"
  :actions {:before check-fucker
            :GET (fn [self]
                   (self:set_title "Cart")
                   (self:render "web.user.cart"))}}
 {:name "user.checkout"
  :path "/user/checkout"
  :actions {:before check-fucker
            :GET (fn [self]
                   (self:set_title "Checkout")
                   (self:render "web.user.checkout"))}}
 {:name "user.purchases"
  :path "/user/purchases"
  :actions {:before check-fucker
            :GET (fn [self]
                   (self:set_title "Purchases")
                   (self:render "web.user.purchases"))}}
 {:name "user.favorites"
  :path "/user/favorites"
  :actions {:before check-fucker
            :GET (fn [self]
                   (self:set_title "Favorites")
                   (self:render "web.user.favorites"))}}]
