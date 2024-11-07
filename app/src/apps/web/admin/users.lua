local lapis = require("common").lapis
local action = lapis.make_action()

function action:GET()
  return { render = "web.admin.users" }
end

return action
