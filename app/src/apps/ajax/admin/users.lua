local lapis = require("common").lapis
local action = lapis.make_action()

function action:POST()
  return lapis.ajax_render("ajax.admin.users")
end

return action
