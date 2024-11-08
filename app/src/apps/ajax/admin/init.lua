local lapis = require("common").lapis
local app = lapis.make_app {
  name="ajax.admin.",
  path="/ajax/admin"
}

app:match("users", "/users", lapis.capture_action(require("apps.ajax.admin.users")))
app:match("manga", "/manga", lapis.capture_action(require("apps.ajax.admin.manga")))
app:match("stats", "/stats", lapis.capture_action(require("apps.ajax.admin.stats")))

return app
