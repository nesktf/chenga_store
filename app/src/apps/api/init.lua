local lapis = require("common").lapis

local app = lapis.make_app{}

app:include("apps.api.core")

return app
