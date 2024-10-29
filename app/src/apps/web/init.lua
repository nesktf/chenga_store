local lapis = require("lapis")
local config = require("lapis.config").get()

local app = lapis.Application()
app.__base = app
function app:include(a)
  self.__class.include(self, a, nil, self)
end

local strings = require("strings")


app:before_filter(function(self)
  self.site_name = config.site_name

  function self:getstr(name)
    return strings[name]
  end

  self.static_url = "/static/%s"
  self.files_url = "/files/%s/%s"

  function self:format_url(pattern, ...)
    self:build_url(string.format(pattern, ...))
  end
end)

app:include("apps.web.admin")
app:include("apps.web.pages")

return app
