local lapis = require("common").lapis

local app = lapis.make_app{
  name = "web.user.",
  path = "/user"
}

app:match("index", "", lapis.capture_action(require("apps.web.user.index")))
app:match("login", "/login", lapis.capture_action(require("apps.web.user.login")))
app:match("cart", "/cart", lapis.capture_action(require("apps.web.user.cart")))
app:match("checkout", "/checkout", lapis.capture_action(require("apps.web.user.checkout")))

return app
