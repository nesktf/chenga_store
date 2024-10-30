local db = require("lapis.db")
local types = require("lapis.validate.types")
local Model = require("lapis.db.model").Model
local throw = require("common").error.throw

local Sales = Model:extend("sales", {
  relations = {
    { "product_sales",  has_many = "ProductSales" },

    { "user",           belongs_to = "Users" },
    { "payment_type",   belongs_to = "PaymentTypes" },
  }
})

Sales.valid_record = types.params_shape{
  { "total", types.number },
  { "user_id", types.db_id },
  { "payment_type_id", types.db_id },
  -- { "date", exists = true },
}

function Sales:new(params)
  local sale, err = self:create(params)
  if (not sale) then
    return throw("err_create_sale", err, params.user_id, params.total)
  end

  return sale
end

function Sales:get(id)
  local sale = self:find{id = id}
  if (not sale) then
    return throw("err_get_sale", "ID not found", id)
  end

  return sale
end

function Sales:modify(id, params)
  local sale, gerr = self:get(id)
  if (not sale) then
    return gerr
  end

  local succ, err = sale:update(params)
  if (not succ) then
    return throw("err_modify_sale", err, id)
  end

  return sale
end

function Sales:delete(id)
  local sale, gerr = self:get(id)
  if (not sale) then
    return gerr
  end

  local succ = sale:delete()
  if (not succ) then
    return throw("err_delete_sale", "Failed to delete sale", id)
  end

  return sale
end

function Sales:get_all()
  return self:select("order by date desc")
end

return Sales
