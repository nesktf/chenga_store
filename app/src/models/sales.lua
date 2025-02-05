local types = require("lapis.validate.types")
local Model = require("lapis.db.model").Model
local error = require("util")
local errcode = error.errcode

local Sales = Model:extend("sales", {
  relations = {
    { "user", belongs_to = "Users" },
    { "manga", belongs_to = "Mangas" }
  }
})

Sales.validate = error.make_validator {
  sale_time = types.number,
  -- sale_time = types.custom(function(val)
  --   if (val == nil) then
  --     return nil, "Sale time can't be null"
  --   end
  --
  --   -- TODO: validate time
  --
  --   return true
  -- end),
  total = types.number,
  user_id = types.db_id,
  manga_id = types.db_id,
}


function Sales:new(params)
  local sale, err = self:create(params)
  if (not sale) then
    return nil, error.errcode_fmt(errcode.db_create,
      "Failed to create sale: %s", err
    )
  end

  return sale
end

function Sales:get(id)
  local sale = self:find{id = id}
  if (not sale) then
    return nil, error.errcode_fmt(errcode.db_select,
      "Sale with id %d not found", id
    )
  end

  return sale
end

function Sales:modify(id, params)
  local sale, gerr = self:get(id)
  if (not sale) then
    return nil, gerr
  end

  local succ, err = sale:update(params)
  if (not succ) then
    return nil, error.errcode_fmt(errcode.db_update,
      "Failed to update sale with id %d: %s", id, err
    )
  end

  return sale
end

function Sales:delete(id)
  local sale, gerr = self:get(id)
  if (not sale) then
    return nil, gerr
  end

  local succ = sale:delete()
  if (not succ) then
    return nil, error.errcode_fmt(errcode.db_delete,
      "Failed to delete sale with id %d", id
    )
  end

  return sale
end

function Sales:get_all()
  return self:select("order by sale_time desc")
end

function Sales:get_total()
  local sum = 0
  for _, sale in ipairs(self:get_all()) do
    sum = sum + sale.total
  end
  return sum
end

return Sales
