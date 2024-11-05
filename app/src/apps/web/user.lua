local lapis = require("common").lapis

local app = lapis.make_app{
  name = "web.user.",
  path = "/user"
}

app:match("index", "", lapis.respond_to((function()
  local action = lapis.make_action()

  function action:GET()
    return { render = "web.user" }
  end

  return action
end)()))

app:match("cart", "/cart", lapis.respond_to((function()
  local action = lapis.make_action()

  function action:GET()
    return { render = "web.cart" }
  end

  return action
end)()))

app:match("payment", "/payment", lapis.respond_to((function()
  local action = lapis.make_action()

  function action:GET()
    return { render = "web.user" }
  end

  return action
end)()))

return app
