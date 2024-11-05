local lapis = require("common").lapis

local app = lapis.make_app{
  name = "web.pages."
}

app:match("index", "/", lapis.respond_to((function()
  local action = lapis.make_action()

  function action:GET()
    return { render = "web.index" }
  end

  return action
end)()))

app:match("search", "/search", lapis.respond_to((function()
  local action = lapis.make_action()

  function action:GET()
    return { render = "web.search" }
  end

  return action
end)()))

app:match("product", "/product", lapis.respond_to((function()
  local action = lapis.make_action()

  function action:GET()
    return { render = "web.product" }
  end

  return action
end)()))

app:match("categories", "/categories", lapis.respond_to((function()
  local action = lapis.make_action()

  function action:GET()
    return { render = "web.categories" }
  end

  return action
end)()))

return app
