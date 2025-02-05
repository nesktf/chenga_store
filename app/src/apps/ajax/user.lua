local u = require("util")

local Mangas = require("models.mangas")
local Users = require("models.users")
local Sales = require("models.sales")
local CartItems = require("models.cart_items")

return {
  path = "/ajax/user",
  name = "ajax.user",

  setup = function(page)
    page:match("cart", "/cart", page.action{
      buy_thing = function(self)
        local user = u.assert(Users:get_by_id(self.params.user_id))
        local cart = user:get_user_cart()
        local cart_items = cart:get_cart_items()

        local sum = 0
        for _, item in ipairs(cart_items) do
          local manga = u.assert(Mangas:get(item.manga_id))
          sum = sum + (manga.price*item.quantity)

          local _ = u.assert(Sales:new {
            sale_time = os.time(),
            total = (manga.price*item.quantity),
            quantity = item.quantity,
            user_id = self.params.user_id,
            manga_id = manga.id
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

        self.user = user
        self.cart = {}

        return self:render("web.user.cart")
      end
    })

    page:match("manga", "/manga", page.action{
      add_fragment = function(self)
        local user = u.assert(Users:get(self.session.user.username))
        local cart = user:get_user_cart()
        local manga = u.assert(Mangas:get(self.params.manga_id))

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
