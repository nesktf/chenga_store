local lapis = require("common").lapis
local error = require("common").error

local app = lapis.make_app{
  name = "api.core.",
  path = "/api",
}

app:match("login", "/login", error.capture_json({
  on_error = error.on_error,
  lapis.respond_to(require("apps.api.core.login"))
}))

app:match("users", "/users", error.capture_json({
  on_error = error.on_error,
  lapis.respond_to(require("apps.api.core.users"))
}))

return app
