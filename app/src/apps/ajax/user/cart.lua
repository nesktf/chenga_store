local lapis = require("common").lapis
local error = require("common").error
local Mangas = require("models.mangas")
local Sales = require("models.sales")
local Users = require("models.users")
local CartItems = require("models.cart_items")

local frag = {}

function frag:buy_thing()
  local user = error.assert(Users:get_by_id(self.params.user_id))
  local cart = user:get_user_cart()
  local cart_items = cart:get_cart_items()

  local sum = 0
  for _, item in ipairs(cart_items) do
    local manga = error.assert(Mangas:get(item.manga_id))
    sum = sum + (manga.price*item.quantity)

    local sale = error.assert(Sales:new {
      sale_time = os.time(),
      total = (manga.price*item.quantity),
      quantity = item.quantity,
      user_id = self.params.user_id,
      manga_id = manga.id
    })
    Mangas:modify(manga.id, { stock = manga.stock - item.quantity })
  end

  for _, item in ipairs(cart_items) do
    error.assert(CartItems:delete(item.id))
  end

  self.cart = {}
  self.buy_message = true

  return lapis.ajax_render("web.user.cart")
end

function frag:remove_things()
  local user = error.assert(Users:get(self.session.user.username))
  local cart = user:get_user_cart()

  local cart_items = cart:get_cart_items()
  for _, item in ipairs(cart_items) do
    item:delete()
  end

  self.user = user
  self.cart = {}

  return lapis.ajax_render("web.user.cart")
end

return lapis.make_ajax_action(frag)
