local lapis = require("common").lapis
local error = require("common").error
local action = lapis.make_action()

local Users = require("models.users")

local function retrieve_users(limit, offset)
  return Users:select("order by username asc limit ? offset ?", limit, offset)
end

function action:GET()
  self.users = error.assert(retrieve_users(10, 0))

  return { render = "web.admin.users" }
end

-- function action:on_error()
-- end

return action
