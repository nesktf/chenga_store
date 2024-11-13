local lapis = require("common").lapis
local error = require("common").error
local action = lapis.make_action()

local Users = require("models.users")

function action:GET()
  return { render = "web.admin.users" }
end

-- function action:on_error()
-- end

return action
