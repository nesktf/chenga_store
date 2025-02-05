local lapis = require("lapis")
local locale = require("locale")
local u = require("util")
local errcode = u.errcode

local app = lapis.Application()
app._base = app
app.include = function(self, a)
  self.__class.include(self, a, nil, self)
end

local function make_page(path)
  local _M = require(path)

  local page = lapis.Application()
  page.name = string.format("%s.", _M.name)
  page.path = _M.path

  page.action = function(action)
    local function req_error()
      return u.err_json(errcode.not_allowed, {
        inf = "Not allowd"
      })
    end
    local base_action = {
      GET = req_error,
      POST = req_error,
      PUT = req_error,
      DELETE = req_error,
    }
    base_action.__index = base_action
    return u.catch(u.respond_to(
      setmetatable(action, base_action)),
      action.on_error or function(self) u.write_error_json(self, errcode.generic) end)
  end

  return _M.setup(page)
end

app:before_filter(function(self)
  self.site_name = u.config.site_name
  self.page_title = self.site_name

  function self:getstr(name)
    return locale.getstr(name)
  end

  self.static_url = "/static/%s"
  self.files_url = "/files/%s/%s"

  function self:format_url(pattern, ...)
    self:build_url(string.format(pattern, ...))
  end

  function self:render(name)
    return { render = name }
  end

  function self:redirect_to(name)
    return { redirect_to = self:url_for(name) }
  end
end)

app:include(make_page("apps.web.index"))
app:include(make_page("apps.web.admin"))
app:include(make_page("apps.web.user"))

return app
