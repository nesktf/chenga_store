local lapis = require("common").lapis
local app = lapis.make_app{}

app:include("apps.ajax.admin")
app:include("apps.ajax.user")

return app
