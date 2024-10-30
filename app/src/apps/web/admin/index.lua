local lapis = require("common").lapis

local action = lapis.make_action()

function action:GET()
  self.page_title = self:getstr("admin")
  return { render = "admin.index" }
end

return action
