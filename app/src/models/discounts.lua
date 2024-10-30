local db = require("lapis.db")
local types = require("lapis.validate.types")
local Model = require("lapis.db.model").Model
local throw = require("common").error.throw

local Discounts = Model:extend("discounts", {
  relations = {
    { "category", belongs_to = "Categories" },
  }
})

Discounts.valid_record = types.params_shape{
  -- { "date_init", exists = true },
  -- { "date_end", exists = true },
  { "value", types.number },
  { "category_id", types.db_id },
}

function Discounts:new(params)
  local disc, err = self:create(params)
  if (not disc) then
    return throw("err_create_discount", err, params.category_id)
  end
  return disc
end

function Discounts:get(id)
  local disc = self:find(id)
  if (not disc) then
    return throw("err_get_discount", "ID not found", id)
  end
  return disc
end

function Discounts:modify(id, params)
  local disc, gerr = self:get(id)
  if (not disc) then
    return gerr
  end

  local succ, err = disc:update(params)
  if (not succ) then
    return throw("err_modify_discount", err, id)
  end
  return disc
end

function Discounts:delete(id)
  local disc, gerr = self:get(id)
  if (not disc) then
    return gerr
  end

  local succ = disc:delete()
  if (not succ) then
    return throw("err_delete_discount", "Failed to delete discount", id)
  end

  return disc
end

function Discounts:get_all()
  return self:select("order by date_end desc")
end

return Discounts
