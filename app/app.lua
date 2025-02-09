local lapis = require("lapis")
local ngx = ngx

local app = lapis.Application()
app._base = app
app.include = function(self, a)
  self.__class.include(self, a, nil, self)
end

app:enable("etlua")
app.layout = require("views.layout")

function app.handle_404()
  local api = ngx.var.uri:match("^(/api).+$")

  if (not api) then
    return { render="code_404" }
  end

  return {
    status = 404,
    json   = { "Resource not found!" }
  }
end

app:include("apps.ajax")
app:include("apps.web")
app:include("apps.api")

return app
