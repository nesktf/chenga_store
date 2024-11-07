local lapis = require("common").lapis
local app = lapis.make_app{
  name = "web.admin.",
  path = "/admin",
}

app:before_filter(function(self)
  if (self.session.name and self.session.name ~= "admin") then
    self.session.name = nil
  end
end)

app:match("index", "", lapis.capture_action(require("apps.web.admin.index")))
app:match("manga", "/manga", lapis.capture_action(require("apps.web.admin.manga")))
app:match("stats", "/stats", lapis.capture_action(require("apps.web.admin.stats")))
app:match("users", "/users", lapis.capture_action(require("apps.web.admin.users")))

return app
