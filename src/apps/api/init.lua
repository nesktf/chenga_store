local lapis = require("lapis")
local u = require("util")

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

  page.make_action = u.make_action

  return _M.setup(page)
end

app:before_filter(function(self)
  function self:render_json(content, status)
    status = status or 0
    if (type(content) == "string") then
      return { json = { status = 0, msg = content } }
    elseif(type(content) == "function") then
      return { json = { status = status, content = content() } }
    elseif(type(content) == "table") then
      return { json = { status = status, content = content } }
    end
  end

  function self:render_ajax(path, content)
    self.ajax_content = content
    return { content_type = "text/plain", render = path, layout = false }
  end
end)

app:include(make_page("apps.api.user"))
app:include(make_page("apps.api.manga"))
-- app:include(make_page("apps.api.admin"))

return app
