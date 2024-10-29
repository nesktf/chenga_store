local lapis = require("lapis")
local app = lapis.Application()
app.__base = app
app.name = "web.admin."
app.path = "/admin"

app:match("admin", "", function(self)
  self.page_title = self:getstr("admin")
  return { render = "admin.index" }
end)

return app
