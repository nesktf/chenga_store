local lapis = require("common").lapis

local app = lapis.make_app{
  name = "web.pages."
}

app:match("index", "/", lapis.respond_to(require("apps.web.pages.index")))
app:match("search", "/search", lapis.respond_to(require("apps.web.pages.search")))
app:match("product", "/product", lapis.respond_to(require("apps.web.pages.product")))
app:match("categories", "/categories", lapis.respond_to(require("apps.web.pages.categories")))

return app
