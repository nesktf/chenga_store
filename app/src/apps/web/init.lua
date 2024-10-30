local lapis = require("common").lapis
local locale = require("locale")

local app = lapis.make_app{}

app:before_filter(function(self)
  self.site_name = lapis.config.site_name

  function self:getstr(name)
    return locale.getstr(name)
  end

  self.static_url = "/static/%s"
  self.files_url = "/files/%s/%s"

  function self:format_url(pattern, ...)
    self:build_url(string.format(pattern, ...))
  end
end)

app:include("apps.web.admin")
app:include("apps.web.pages")
app:include("apps.web.user")

return app
