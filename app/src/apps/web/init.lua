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

app:include((function()
  local pages = lapis.make_app {
    name = "web."
  }

  pages:match("index", "/", lapis.capture_action(require("apps.web.index")))
  pages:match("manga", "/manga", lapis.capture_action(require("apps.web.manga")))
  pages:match("search", "/search", lapis.capture_action(require("apps.web.search")))

  return pages
end)())

app:include("apps.web.admin")
app:include("apps.web.user")

return app
