local u = require("util")

local Users = require("models.users")
local UserFavs = require("models.user_favs")
local UserCarts = require("models.user_carts")
local CartItems = require("models.cart_items")
local Mangas = require("models.mangas")

return {
  path = "/api/user",
  name = "api.user",

  setup = function(page)
    page:match("favorites", "/favorites", page.make_action{
      parse_json = true,
      before = function(self)
        u.assert(self.params.username, u.errcode_fmt(u.errcode.field_invalid, "No user provided"))
      end,
      GET = function(self)
        local user = u.assert(Users:get(self.params.username))
        local out = {}
        for _,fav in pairs(user:get_user_favs()) do
          local manga = u.assert(Mangas:get(fav.manga_id))
          table.insert(out, {
            name = manga.name,
            image = manga.image_path,
            price = manga.price*0.01,
            url = self:url_for('web.manga', { id = manga.id })
          })
        end

        return self:render_json(out)
      end,
      POST = function(self)
        u.assert(self.params.manga_id, u.errcode_fmt(u.errcode.field_invalid, "No manga provided"))
        local user = u.assert(Users:get(self.params.username))
        local ufav = UserFavs:find_favorite(user.id, self.params.manga_id)
        if (ufav) then
          u.throw(u.errcode_fmt(u.errcode.field_invalid, "Favorite already exists"))
        end
        u.assert(UserFavs:new{user_id = user.id, manga_id = self.params.manga_id})

        return self:render_json("ok")
      end,
      DELETE = function(self)
        local user = u.assert(Users:get(self.params.username))
        if (self.params.drop) then
          u.assert(UserFavs:drop_user(user.id))
          return self:render_json("ok")
        end

        u.assert(self.params.manga_id, u.errcode_fmt(u.errcode.field_invalid, "No manga provided"))
        local ufav = UserFavs:find_favorite(user.id, self.params.manga_id)
        if (not ufav) then
          u.throw(u.errcode_fmt(u.errcode.field_not_found, "Favorite not found"))
        end
        ufav:delete()

        return self:render_json("ok")
      end,
      PUT = function(self)
        u.assert(self.params.manga_id, u.errcode_fmt(u.errcode.field_invalid, "No manga provided"))
        local user = u.assert(Users:get(self.session.user.username))
        local ufav = UserFavs:find_favorite(user.id, self.params.id)
        if (not ufav) then
          u.assert(UserFavs:new{user_id = user.id, manga_id = self.params.manga_id})
        else
          ufav:delete()
        end

        return self:render_json(ufav and "removed" or "added")
      end,
    })

    page:match("cart", "/cart", page.make_action{
      parse_json = true,
      before = function(self)
        u.assert(self.params.username, u.errcode_fmt(u.errcode.field_invalid, "No user provided"))
      end,
      GET = function(self)
        local user = u.assert(Users:get(self.params.username))
        local cart = user:get_user_cart()
        local out = {}
        for _,item in pairs(cart:get_cart_items()) do
          local manga = u.assert(Mangas:get(item.manga_id))
          table.insert(out, {
            item_id = item.id,
            name = manga.name,
            image = manga.image_path,
            price = manga.price*0.01,
            quantity = item.quantity,
            url = self:url_for('web.manga', { id = manga.id })
          })
        end

        return self:render_json(out)
      end,
      POST = function(self)
        u.assert(self.params.manga_id, u.errcode_fmt(u.errcode.field_invalid, "No manga provided"))
        u.assert(self.params.quantity, u.errcode_fmt(u.errcode.field_invalid, "No quant provided"))

        local user = u.assert(Users:get(self.params.username))
        local manga = u.assert(Mangas:get(self.params.manga_id))
        local cart = user:get_user_cart()

        u.assert(CartItems:new {
          quantity = self.params.quantity,
          manga_id = manga.id,
          user_cart_id = cart.id,
        })

        u.assert(UserCarts:modify(cart.id, {
          subtotal = cart.subtotal + (manga.price*self.params.quantity),
        }))

        return self:render_json("ok")
      end,
      DELETE = function(self)
        local user = u.assert(Users:get(self.params.username))
        local cart = user:get_user_cart()
        if (self.params.drop) then
          for _, item in pairs(cart:get_cart_items()) do
            item:delete()
          end
          u.assert(UserCarts:modify(cart.id, {
            subtotal = 0,
          }))

          return self:render_json("ok")
        end

        u.assert(self.params.item_id, u.errcode_fmt(u.errcode.field_invalid, "No item provided"))

        local cart_item = u.assert(CartItems:get(self.params.item_id))
        local manga = u.assert(Mangas:get(cart_item.manga_id))
        local quant = cart_item.quantity
        cart_item:delete()

        u.assert(UserCarts:modify(cart.id, {
          subtotal = cart.subtotal - (manga.price*quant)
        }))

        return self:render_json("ok")
      end,
    })

    return page
  end
}
