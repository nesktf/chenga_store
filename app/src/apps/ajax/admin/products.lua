local lapis = require("common").lapis
local error = require("common").error

local action = lapis.make_action()

local function render_prods(self)
  self.prod_max_index = 2
  self.prod_index = self.params.index and tonumber(self.params.index) or 0
  self.prods = (function()
    local prods = {}

    for i = 0 + self.prod_index*10, 9 + self.prod_index*10, 1 do
      table.insert(prods, {
        name="prod"..tostring(i),
        value=i,
      })
    end

    return prods
  end)()
  return { render = "ajax.admin.products" }
end

local function render_submit_form(_)
  return { render = "ajax.admin.newprod" }
end

local function submit_prod(self)
  return string.format("tings: %s %s %s", 
    self.params.prod_name, self.params.prod_stock, self.params.prod_provider)
end

function action:POST()
  local frag = self.params.frag
  error.assert(frag)

  if (frag == "newprod") then
    return render_submit_form(self)
  end

  if (frag == "products") then
    return render_prods(self)
  end

  if (frag == "submit_prod") then
    return submit_prod(self)
  end

  error.yield("Invalid fragment")
end

function action:on_error()
  return { render = "ajax.error" }
end

return action
