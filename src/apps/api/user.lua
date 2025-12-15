local u = require("util")
local cjson = require("cjson")

local Users = require("models.users")
local UserFavs = require("models.user_favs")
local UserCarts = require("models.user_carts")
local CartItems = require("models.cart_items")
local SaleCart = require("models.sale_cart")
local Sales = require("models.sales")
local Mangas = require("models.mangas")

local function price_fmt(price)
  return string.format("$%.2f", price*0.01)
end

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
            id = manga.id,
            name = manga.name,
            image = manga.image_path:sub(2),
            price = price_fmt(manga.price),
            stock = manga.stock,
            url = self:url_for('web.manga', { id = manga.id })
          })
        end

        return self:render_json({
          items = #out == 0 and cjson.empty_array or out,
        })
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
        else
          ufav:delete()
        end

        return self:render_json("ok")
      end,
      PUT = function(self)
        u.assert(self.params.manga_id, u.errcode_fmt(u.errcode.field_invalid, "No manga provided"))
        local user = u.assert(Users:get(self.session.user.username))
        local ufav = UserFavs:find_favorite(user.id, self.params.manga_id)
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

        local sum = 0
        for _,item in pairs(cart:get_cart_items()) do
          local manga = u.assert(Mangas:get(item.manga_id))
          sum = sum + manga.price*item.quantity
          table.insert(out, {
            item_id = item.id,
            name = manga.name,
            image = manga.image_path:sub(2),
            price = price_fmt(manga.price),
            quantity = item.quantity,
            total_item = price_fmt(manga.price*item.quantity),
            url = self:url_for('web.manga', { id = manga.id })
          })
        end

        return self:render_json({
          items = #out == 0 and cjson.empty_array or out,
          total = price_fmt(sum),
        })
      end,
      POST = function(self)
        u.assert(self.params.manga_id, u.errcode_fmt(u.errcode.field_invalid, "No manga provided"))
        u.assert(self.params.quantity, u.errcode_fmt(u.errcode.field_invalid, "No quant provided"))

        local user = u.assert(Users:get(self.params.username))
        local manga = u.assert(Mangas:get(self.params.manga_id))
        local cart = user:get_user_cart()

        local item = CartItems:find({
          user_cart_id = cart.id,
          manga_id = manga.id,
        })

        if (item) then
          local q = item.quantity+self.params.quantity
          u.assert(q <= manga.stock, u.errcode_fmt(u.errcode.field_invalid, "Not enough stock!"))
          CartItems:modify(item.id, { quantity = q })
          u.assert(UserCarts:modify(cart.id, {
            subtotal = cart.subtotal + (manga.price*self.params.quantity),
          }))
          return self:render_json({
            left = manga.stock-q
          })
        end

        u.assert(CartItems:new {
          quantity = self.params.quantity,
          manga_id = manga.id,
          user_cart_id = cart.id,
        })

        u.assert(UserCarts:modify(cart.id, {
          subtotal = cart.subtotal + (manga.price*self.params.quantity),
        }))

        return self:render_json({
          left = manga.stock - self.params.quantity,
        })
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

    page:match("checkout", "/checkout", page.make_action{
      parse_json = true,
      before = function(self)
        u.assert(self.params.username, u.errcode_fmt(u.errcode.field_invalid, "No user provided"))
      end,
      POST = function(self)
        local user = u.assert(Users:get(self.params.username))
        local cart = user:get_user_cart()
        local cart_items = cart:get_cart_items()

        local discount = 1

        local sale_cart = u.assert(SaleCart:new{
          sale_time = os.time(),
          subtotal = cart.subtotal,
          discount = discount,
          total = (cart.subtotal*discount),
          user_id = user.id,
        })

        for _, item in ipairs(cart_items) do
          local manga = u.assert(Mangas:get(item.manga_id))
          local _ = u.assert(Sales:new {
            quantity = item.quantity,
            sale_cart_id = sale_cart.id,
            manga_id = manga.id,
          })

          Mangas:modify(manga.id, { stock = manga.stock - item.quantity })
        end

        for _, item in ipairs(cart_items) do
          u.assert(CartItems:delete(item.id))
        end
        UserCarts:modify(cart.id, { subtotal = 0 })

        return self:render_json("ok")
      end,
    })

    page:match("purchases", "/purchases", page.make_action{
      parse_json = true,
      before = function(self)
        u.assert(self.params.username, u.errcode_fmt(u.errcode.field_invalid, "No user provided"))
      end,
      GET = function(self)
        local user = u.assert(Users:get(self.params.username))
        local out = {}

        local sum = 0
        for _, cart in pairs(user:get_sale_cart()) do
          local items = {}
          for _, sale in pairs(cart:get_sales()) do
            local manga = u.assert(Mangas:get(sale.manga_id))
            table.insert(items, {
              name = manga.name,
              image = manga.image_path:sub(2),
              price = price_fmt(manga.price),
              quantity = sale.quantity,
              total_item = price_fmt(manga.price*sale.quantity),
              url = self:url_for('web.manga', { id = manga.id })
            })
          end
          table.insert(out, {
            sale_time = cart.sale_time,
            total = price_fmt(cart.total),
            subtotal = price_fmt(cart.subtotal),
            discount = string.format("%.2f%%", (1-cart.discount)*0.01),
            items = items,
          })
          sum = sum + cart.total
        end

        return self:render_json({
          total = price_fmt(sum),
          purchases = #out == 0 and cjson.empty_array or out,
        })
      end,
    })

    return page
  end
}
