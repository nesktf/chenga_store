local lapis = require("lapis")
local app = lapis.Application()

app:match("index", "/", require("apps.web.index"))

return app
