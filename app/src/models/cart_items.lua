local types = require("lapis.validate.types")
local Model = require("lapis.db.model").Model
local error = require("common").error
local errcode = error.code

local CartItems = Model:extend("cart_items", {
  relations = {
    { "user", belongs_to = "Users" },
    { "manga", belongs_to = "Mangas" },
  }
})

CartItems.validate = error.make_validator {
  price = types.number,
  quantity = types.number,
  subtotal = types.number,
  discount = types.number,
  total = types.number,
  user_id = types.db_id,
  manga_id = types.db_id,
}


function CartItems:new(params)
  local citem, err = self:create(params)
  if (not citem) then
    return errcode.db_create("Failed to add manga with id %d to cart %d: %s",
      params.manga_id, params.user_id, err)
  end

  return citem
end

function CartItems:get(id)
  local citem = self:find{ id = id }
  if (not citem) then
    return errcode.db_select("Cart item with id %d not found", id)
  end

  return citem
end

function CartItems:modify(id, params)
  local citem, gerr = self:get(id)
  if (not citem) then
    return errcode.db_update(gerr)
  end

  local succ, err = citem:update(params)
  if (not succ) then
    return errcode.db_update("Failed to update cart item with id %d: %s", id, err)
  end

  return citem
end

function CartItems:delete(id)
  local citem, gerr = self:get(id)
  if (not citem) then
    return errcode.db_delete(gerr)
  end

  local succ = citem:delete()
  if (not succ) then
    return errcode.db_delete("Failed to delete cart item with id %d", id)
  end

  return citem
end

function CartItems:get_from_user(id)
  return self:select("where user_id = ?", id)
end

return CartItems
