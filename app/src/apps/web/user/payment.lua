local lapis = require("common").lapis

local action = lapis.make_action()

function action:GET()
  return { render = "user.payment" }
end

return action