local lapis = require("common").lapis
local error = require("common").error
local errcode = error.code
local Users = require("models.users")
local Mangas = require("models.mangas")

local CartItems = require("models.cart_items")

local frag = {}

function frag:add_fragment()
  local user = error.assert(Users:get(self.session.user.username))
  local cart = user:get_user_cart()
  local manga = error.assert(Mangas:get(self.params.manga_id))

  error.assert(CartItems:new {
    quantity = self.params.quantity,
    manga_id = manga.id,
    user_cart_id = cart.id,
  })

  self.error_title = "Item added to cart"
  self.errors = {
    {what="", code=0}
  }

  return lapis.ajax_render("ajax.error")
end

return lapis.make_ajax_action(frag)
