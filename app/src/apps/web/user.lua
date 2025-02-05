local u = require("util")

local Mangas = require("models.mangas")
local Users = require("models.users")

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
      quantity = item.quantity,
      manga = manga,
    })
  end
  self.cart_total = string.format("$%.2f", sum)
end

local function login_user(self)
  local params = {
    username = self.params.username,
    password = self.params.password,
  }

  local user = u.assert(Users:login(params))

  self.session.user = {
    username = user.username,
    is_admin = user.is_admin,
  }

  return self:redirect_to("web.index")
end

local function register_user(self)
  local params = u.assert(Users:validate {
    name = self.params.name,
    address = self.params.address,
    email = self.params.email,
    username = self.params.username,
    password = self.params.password,
    is_admin = false -- Must modify it manually
  })

  local user = u.assert(Users:new(params))

  self.session.user = {
    username = user.username,
    is_admin = user.is_admin,
  }

  return self:redirect_to("web.index")
end

return {
  name = "web.user",
  path = "/user",

  setup = function(page)
    page:match("index", "", page.action{
      GET = function(self)
        if (not self.session.user) then
          return self:redirect_to("web.user.login")
        end

        return self:render("web.user.index")
      end,
    })
    page:match("login", "/login", page.action{
      on_error = function(_)
        return { render = "web.user.login" }
      end,
      GET = function(self)
        if (self.params.logout) then
          self.session.user = nil
          return self:redirect_to("web.index")
        end

        if (self.session.user) then
          return self:redirect_to("web.index")
        end

        return self:render("web.user.login")
      end,
      POST = function(self)
        if (self.params.logout) then
          self.session.user = nil
          return self:redirect_to("web.index")
        end

        if (self.session.user) then
          return self:redirect_to("web.index")
        end

        if (self.params.login) then
          return login_user(self)
        end

        if (self.params.register) then
          return register_user(self)
        end

        return self:render("web.user.login")
      end,
    })
    page:match("cart", "/cart", page.action{
      GET = function(self)
        if (not self.session.user) then
          return self:redirect_to("web.user.login")
        end

        self.page_title = self:getstr("cart")
        populate_cart_garbage(self)
        return self:render("web.user.cart")
      end,
      POST = function(self)
        if (not self.session.user) then
          return self:redirect_to("web.user.login")
        end

        self.page_title = self:getstr("cart")
        populate_cart_garbage(self)
        return self:render("web.user.cart")
      end,
    })
    page:match("checkout", "/checkout", page.action{
      GET = function(self)
        if (not self.session.user) then
          return self:redirect_to("web.user.login")
        end

        return self:render("web.user.checkout")
      end,
    })
    return page
  end,
}
