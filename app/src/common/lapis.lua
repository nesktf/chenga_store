local lapis = require("lapis")
local ngx = ngx

local base_action = (function()
  local action = {}
  function action.error()
    return {
      status = ngx.HTTP_NOT_ALLOWED,
      json = {},
    }
  end

  action.__index = action
  action.GET = action.error
  action.POST = action.error
  action.PUT = action.error
  action.DELETE = action.error

  return action
end)()

local _M = {}

_M.config = require("lapis.config").get()
_M.respond_to = require("lapis.application").respond_to

function _M.make_action()
  return setmetatable({}, base_action)
end

function _M.make_app(params)
  local app = lapis.Application()
  app._base = app
  if (params.name) then app.name = params.name end
  if (params.path) then app.path = params.path end

  function app:include(a)
    self.__class.include(self, a, nil, self)
  end

  return app
end

return _M
