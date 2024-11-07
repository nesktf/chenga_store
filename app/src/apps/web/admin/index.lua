local lapis = require("common").lapis
local error = require("common").error
local action = lapis.make_action()

local function verify_admin(params)
  if (not params.username or not params.password) then
    return false, "Invalid parameters"
  end

  if (params.username == "test" and params.password == "test") then
    return "admin"
  end

  return false, "Invalid parameters"
end

function action:before()
  self.page_title = self:getstr("admin")
end

function action:GET()
  error.assert(self.session.name, "Invalid session")
  return { render = "web.admin.index" }
end

function action:POST()
  if (self.params.logout) then
    self.session.name = nil
    return { redirect_to = self:url_for("web.admin.index") }
  end
  error.assert(self.params.login ~= nil or self.session.name ~= nil, "Invalid POST")

  if (self.params.login) then
    local username = error.assert(verify_admin(self.params))
    self.session.name = username
  end

  return { redirect_to = self:url_for("web.admin.index") }
end

function action:on_error()
  return { render = "web.admin.login" }
end

return action
