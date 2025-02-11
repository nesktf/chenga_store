local lapis = require("lapis")
local config = require("util").config
local ngx = ngx

local app = lapis.Application()
app._base = app
app.include = function(self, a)
  self.__class.include(self, a, nil, self)
end

app:enable("etlua")
app.layout = require("views.layout")

function app.handle_404(self)
  local api = ngx.var.uri:match("^(/api).+$")

  if (not api) then
    self.page_title = config.site_name.." - 404"
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
