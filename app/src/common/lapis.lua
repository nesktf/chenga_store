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

function _M.make_ajax_action(frags)
  local action = _M.make_action()

  function action:POST()
    if (not self.params.__ajax_frag) then
      error.yield(error.code.field_not_found, "No fragment provided")
    end
    local frag = self.params.__ajax_frag

    local frag_fun = frags[frag]
    if (not frag_fun) then
      error.yield(error.code.field_invalid, "Fragment not found %s", frag)
    end
    return frag_fun(self)
  end

  if (frags.on_error and type(frags.on_error) == "function") then
    action.on_error = frags.on_error
  else
    action.on_error = function(_)
      return _M.ajax_render("ajax.error")
    end
  end

  return action
end

return _M
