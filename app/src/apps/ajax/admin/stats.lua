local lapis = require("common").lapis
local error = require("common").error

local action = lapis.make_action()

function action:POST()
  return { render = "ajax.admin.stats" }
end


return action
