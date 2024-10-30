local lapis = require("common").lapis
local error = require("common").error
local Users = require("models").users
local ngx = ngx

local action = lapis.make_action()

function action:POST()
  local params = {
    username = self.params.username,
    password = self.params.password,
  }

  local user = error.assert(Users:login(params))
  return {
    status = ngx.HTPP_OK,
    json = {
      id = user.id,
      username = user.username,
    }
  }
end

return action
