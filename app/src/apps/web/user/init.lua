local lapis = require("common").lapis

local app = lapis.make_app{
  name = "web.user.",
  path = "/user"
}

app:match("user", "", lapis.respond_to(require("apps.web.user.index")))
app:match("cart", "/cart", lapis.respond_to(require("apps.web.user.cart")))
app:match("payment", "/payment", lapis.respond_to(require("apps.web.user.payment")))

return app
