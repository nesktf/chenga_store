local lapis = require("common").lapis

local action = lapis.make_action()

function action:GET()
  return { render = "pages.search" }
end

return action