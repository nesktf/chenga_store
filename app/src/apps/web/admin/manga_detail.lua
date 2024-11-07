local lapis = require("common").lapis
local action = lapis.make_action()

function action:GET()
  return { render = "web.admin.manga_detail" }
end

return action
