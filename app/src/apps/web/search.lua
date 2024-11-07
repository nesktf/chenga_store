local lapis = require("common").lapis

local action = lapis.make_action()

function action:GET()
  self.page_title = self:getstr("search")
  return { render = "web.search" }
end

return action
