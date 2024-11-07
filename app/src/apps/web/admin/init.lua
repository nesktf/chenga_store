local lapis = require("common").lapis
local app = lapis.make_app{
  name = "web.admin.",
  path = "/admin",
}

app:match("index", "", lapis.capture_action(require("apps.web.admin.index")))
app:match("manga", "/manga", lapis.capture_action(require("apps.web.admin.manga")))
app:match("users", "/users", lapis.capture_action(require("apps.web.admin.users")))
app:match("manga_detail", "/manga_detail", 
  lapis.capture_action(require("apps.web.admin.manga_detail")))
app:match("user_detail", "/user_detail",
  lapis.capture_action(require("apps.web.admin.user_detail")))

return app
