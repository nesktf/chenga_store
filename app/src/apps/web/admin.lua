local lapis = require("common").lapis

local app = lapis.make_app{
  name = "web.admin.",
  path = "/admin",
}

app:match("index", "", lapis.respond_to((function() 
  local action = lapis.make_action()

  function action:GET()
    self.page_title = self:getstr("admin")
    return { render = "web.admin" }
  end

  return action
end)()))

return app
