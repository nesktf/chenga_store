local types = require("lapis.validate.types")
local Model = require("lapis.db.model").Model
local error = require("common").error
local errcode = error.code

local Sales = Model:extend("sales", {
  relations = {
    { "user", belongs_to = "Users" },
  }
})

Sales.validate = error.make_validator {
  { "sale_time", types.custom(function(val)
    if (val == nil) then
      return nil, "Sale time can't be null"
    end

    -- TODO: validate time

    return true
  end)},
  { "total", types.number },
  { "user_id", types.db_id:is_optional() },
}


function Sales:new(params)
  local sale, err = self:create(params)
  if (not sale) then
    return errcode.db_create("Failed to create sale: %s", err)
  end

  return sale
end

function Sales:get(id)
  local sale = self:find{id = id}
  if (not sale) then
    return errcode.db_select("Sale with id %d not found", id)
  end

  return sale
end

function Sales:modify(id, params)
  local sale, gerr = self:get(id)
  if (not sale) then
    return errcode.db_update(gerr)
  end

  local succ, err = sale:update(params)
  if (not succ) then
    return errcode.db_update("Failed to update sale with id %d: %s", id, err)
  end

  return sale
end

function Sales:delete(id)
  local sale, gerr = self:get(id)
  if (not sale) then
    return errcode.db_delete(gerr)
  end

  local succ = sale:delete()
  if (not succ) then
    return errcode.db_delete("Failed to delete sale with id %d", id)
  end

  return sale
end

function Sales:get_all()
  return self:select("order by date desc")
end

return Sales
