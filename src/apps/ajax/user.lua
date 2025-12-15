local u = require("util")

local Mangas = require("models.mangas")
local Users = require("models.users")
local Sales = require("models.sales")
local SaleCart = require("models.sale_cart")
local UserCarts = require("models.user_carts")
local CartItems = require("models.cart_items")

local function populate_cart_garbage(self)
  local user = u.assert(Users:get(self.session.user.username))
  local cart = user:get_user_cart()

  local cart_items = cart:get_cart_items()

  self.user = user
  self.cart = {}
  local sum = 0
  for _, item in ipairs(cart_items) do
    local manga = u.assert(Mangas:get(item.manga_id))
    sum = sum + (manga.price/100)*item.quantity
    table.insert(self.cart, {
      id = item.id,
      quantity = item.quantity,
      manga = manga,
    })
  end
  self.cart_total = string.format("$%.2f", sum)
end

return {
  path = "/ajax/user",
  name = "ajax.user",

  setup = function(page)
    page:match("cart", "/cart", page.action{
      buy_thing = function(self)
        local user = u.assert(Users:get_by_id(self.params.user_id))
        local cart = user:get_user_cart()
        local cart_items = cart:get_cart_items()

        local discount = 1

        local sale_cart = u.assert(SaleCart:new{
          sale_time = os.time(),
          subtotal = cart.subtotal,
          discount = discount,
          total = (cart.subtotal*discount),
          user_id = self.params.user_id,
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

        self.cart = {}
        self.buy_message = true

        return self:render("web.user.cart")
      end,

      remove_things = function(self)
        local user = u.assert(Users:get(self.session.user.username))
        local cart = user:get_user_cart()

        local cart_items = cart:get_cart_items()
        for _, item in ipairs(cart_items) do
          item:delete()
        end
        u.assert(UserCarts:modify(cart.id, {
          subtotal = 0,
        }))

        self.user = user
        self.cart = {}

        return self:render("web.user.cart")
      end,

      remove_single_thing = function(self)
        local user = u.assert(Users:get(self.session.user.username))
        local cart = user:get_user_cart()
        local cart_item = u.assert(CartItems:get(self.params.item_cart_id))
        local manga = u.assert(Mangas:get(cart_item.manga_id))

        u.assert(UserCarts:modify(cart.id, {
          subtotal = cart.subtotal - (manga.price*cart_item.quantity)
        }))

        cart_item:delete()
        self.user = user
        populate_cart_garbage(self)

        return self:render("web.user.cart")
      end,
    })

    page:match("manga", "/manga", page.action{
      add_fragment = function(self)
        local user = u.assert(Users:get(self.session.user.username))
        local cart = user:get_user_cart()
        local manga = u.assert(Mangas:get(self.params.manga_id))

        u.assert(UserCarts:modify(cart.id, {
          subtotal = cart.subtotal + (manga.price*self.params.quantity),
        }))

        u.assert(CartItems:new {
          quantity = self.params.quantity,
          manga_id = manga.id,
          user_cart_id = cart.id,
        })

        self.error_title = "Item added to cart"
        self.errors = {
          {what="", status=0}
        }

        return self:render("ajax.error")
      end,
    })

    return page
  end,
}
