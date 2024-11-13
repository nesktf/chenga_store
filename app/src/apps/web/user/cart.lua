local lapis = require("common").lapis
local action = lapis.make_action()
local error = require("common").error
local Mangas = require("models.mangas")
local Users = require("models.users")

local function populate_garbage(self)
  local user = error.assert(Users:get(self.session.user.username))
  local cart = user:get_user_cart()

  local cart_items = cart:get_cart_items()

  self.user = user
  self.cart = {}
  local sum = 0
  for _, item in ipairs(cart_items) do
    local manga = error.assert(Mangas:get(item.manga_id))
    sum = sum + (manga.price/100)*item.quantity
    table.insert(self.cart, {
      quantity = item.quantity,
      manga = manga,
    })
  end
  self.cart_total = string.format("$%.2f", sum)
end

function action:GET()
  if (not self.session.user) then
    return { redirect_to = self:url_for("web.user.login") }
  end

  self.page_title = self:getstr("cart")
  populate_garbage(self)
  return { render = "web.user.cart" }
end

function action:POST()
  if (not self.session.user) then
    return { redirect_to = self:url_for("web.user.login") }
  end

  populate_garbage(self)

  return { render = "web.user.cart" }
end

return action
