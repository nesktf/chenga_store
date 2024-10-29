local lapis = require("lapis")
local app = lapis.Application()

app:match("login", "/login", require("apps.api.login"))

return app
