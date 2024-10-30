local lapis = require("common").lapis

local app = lapis.make_app{
  name = "web.admin.",
  path = "/admin",
}

app:match("admin", "", lapis.respond_to(require("apps.web.admin.index")))

return app
