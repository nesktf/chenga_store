local lapis = require("common").lapis
local app = lapis.make_app{
  name = "web.admin.",
  path = "/admin",
}

app:match("index", "", lapis.capture_action(require("apps.web.admin.index")))
app:match("manga", "/manga", lapis.capture_action(require("apps.web.admin.manga")))
app:match("users", "/users", lapis.capture_action(require("apps.web.admin.users")))

return app
