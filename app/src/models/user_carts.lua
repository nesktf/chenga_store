local types = require("lapis.validate.types")
local Model = require("lapis.db.model").Model
local error = require("common").error
local errcode = error.code

local UserCarts = Model:extend("user_carts", {
  relations = {
    { "user", belongs_to = "Users" },
    { "cart_items", has_many = "CartItems" }
  }
})

UserCarts.validate = error.make_validator {
  subtotal = types.number,
  discount = types.number,
  total = types.number,
  user_id = types.db_id,
}

function UserCarts:new(params)
  local ucart, err = self:create(params)
  if (not ucart) then
    return errcode.db_create("Failed to create user cart '%d': %s", params.user_id, err)
  end

  return ucart
end

function UserCarts:get(id)
  local ucart = self:find{ id = id }
  if (not ucart) then
    return errcode.db_select("Cart with id '%d' not found", id)
  end

  return ucart
end

function UserCarts:modify(id, params)
  local ucart, gerr = self:get(id)
  if (not ucart) then
    return errcode.db_update(gerr)
  end

  local succ, err = ucart:update(params)
  if (not succ) then
    return errcode.db_update("Error updating cart '%d': %s", id, err)
  end

  return ucart
end

function UserCarts:delete(id)
  local ucart, gerr = self:get(id)
  if (not ucart) then
    return errcode.db_delete(gerr)
  end

  for _, item in ipairs(ucart:get_cart_items()) do
    item:delete()
  end

  local succ = ucart:delete()
  if (not succ) then
    return errcode.db_delete("Error deleting cart '%d'", id)
  end

  return ucart
end

return UserCarts
