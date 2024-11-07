local lapis = require("common").lapis
local error = require("common").error
local action = lapis.make_action()
local Users = require("models.users")

local function login_user(self)
  local params = {
    username = self.params.username,
    password = self.params.password,
  }

  local user = error.assert(Users:login(params))

  self.session.user = {
    username = user.username,
    is_admin = user.is_admin,
  }

  return { redirect_to = self:url_for("web.index") }
end

local function register_user(self)
  local params = error.assert(Users:validate {
    name = self.params.name,
    address = self.params.address,
    email = self.params.email,
    username = self.params.username,
    password = self.params.password,
    is_admin = false -- Must modify it manually
  })

  local user = error.assert(Users:new(params))

  self.session.user = {
    username = user.username,
    is_admin = user.is_admin,
  }

  return { redirect_to = self:url_for("web.index") }
end

function action:GET()
  if (self.params.logout) then
    self.session.user = nil
    return { redirect_to = self:url_for("web.index") }
  end

  if (self.session.user) then
    return { redirect_to = self:url_for("web.index") }
  end

  return { render = "web.user.login" }
end

function action:POST()
  if (self.params.logout) then
    self.session.user = nil
    return { redirect_to = self:url_for("web.index") }
  end

  if (self.session.user) then
    return { redirect_to = self:url_for("web.index") }
  end

  if (self.params.login) then
    return login_user(self)
  end

  if (self.params.register) then
    return register_user(self)
  end

  return { render = "web.user.login" }
end

function action:on_error()
  return { render = "web.user.login" }
end

return action
