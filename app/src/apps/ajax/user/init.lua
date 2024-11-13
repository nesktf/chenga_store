local lapis = require("common").lapis
local app = lapis.make_app {
  name="ajax.user.",
  path="/ajax/user"
}

app:match("cart", "/cart", lapis.capture_action(require("apps.ajax.user.cart")))
app:match("manga", "/manga", lapis.capture_action(require("apps.ajax.user.manga")))

return app
