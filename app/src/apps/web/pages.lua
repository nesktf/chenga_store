local lapis = require("lapis")
local app = lapis.Application()
app.__base = app
app.name = "web.pages."

app:match("index", "/", function(self)
  return { render = "pages.index" }
end)

app:match("search", "/search", function(self)
  return { render = "pages.search" }
end)

app:match("cart", "/cart", function(self)
  return { render = "pages.cart" }
end)

app:match("product", "/product", function(self)
  return { render = "pages.product" }
end)

app:match("user", "/user", function(self)
  return { render = "pages.user" }
end)

return app
