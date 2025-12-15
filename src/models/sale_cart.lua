local types = require("lapis.validate.types")
local Model = require("lapis.db.model").Model
local u = require("util")
local errcode = u.errcode

local SaleCart = Model:extend("sale_cart", {
  relations = {
    { "user", belongs_to = "Users" },
    { "sales", has_many = "Sales" },
  }
})

SaleCart.validate = u.make_validator {
  sale_time = types.number,
  subtotal = types.number,
  discount = types.number,
  total = types.number,
  user_id = types.db_id,
}

function SaleCart:new(params)
  local scart, err = self:create(params)
  if (not scart) then
    return nil, u.errcode_fmt(errcode.db_create,
      "Failed to create sale cart: %s", err
    )
  end
  return scart
end

function SaleCart:get(id)
  local scart = self:find{id = id}
  if (not scart) then
    return nil, u.errcode_fmt(errcode.db_select,
      "Sale cart with id %d not found", id
    )
  end
  return scart
end

function SaleCart:modify(id, params)
  local scart, gerr = self:get(id)
  if (not scart) then
    return nil, gerr
  end

  local succ, err = scart:update(params)
  if (not succ) then
    return nil, u.errcode_fmt(errcode.db_update,
      "Failed to update sale cart with id %d: %s", id, err
    )
  end

  return scart
end

function SaleCart:delete(id)
  local scart, gerr = self:get(id)
  if (not scart) then
    return nil, gerr
  end

  local succ = scart:delete()

  if (not succ) then
    return nil, u.errcode_fmt(errcode.db_delete,
      "Failed to delete sale cart with id %d", id
    )
  end

  return scart
end

function SaleCart:get_all()
  return self:select("order by sale_time desc")
end

function SaleCart:get_total()
  local sum = 0
  for _, sale in ipairs(self:get_all()) do
    sum = sum + sale.total
  end
  return sum
end

return SaleCart
