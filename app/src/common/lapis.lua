local lapis = require("lapis")
local error = require("common.error")
local ngx = ngx

local _base_action = (function()
  local function _req_error()
    return {
      status = ngx.HTTP_NOT_ALLOWED,
      json = {
        info = "Not allowed"
      },
    }
  end

  local action = {}

  action.__index = action
  action.GET = _req_error
  action.POST = _req_error
  action.PUT = _req_error
  action.DELETE = _req_error
  action.on_error = error.on_error

  return action
end)()

local _M = {}

_M.config = require("lapis.config").get()
_M.respond_to = require("lapis.application").respond_to

function _M.make_action()
  return setmetatable({}, _base_action)
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

function _M.capture_action(action)
  return error.capture{
    on_error = action.on_error,
    _M.respond_to(action)
  }
end

function _M.capture_action_json(action)
  return error.capture_json{
    on_error = action.on_error,
    _M.respond_to(action)
  }
end

function _M.ajax_render(view)
  return { render = view, layout = false }
end

return _M
