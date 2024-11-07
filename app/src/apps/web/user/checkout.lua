local lapis = require("common").lapis
local action = lapis.make_action()

function action:GET()
  if (not self.session.user) then
    return { redirect_to = self:url_for("web.user.login") }
  end

  return { render = "web.user.checkout" }
end

return action
