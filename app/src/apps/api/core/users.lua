local lapis = require("common").lapis

local action = lapis.make_action()

function action:GET()
  return "users"
end

return action
