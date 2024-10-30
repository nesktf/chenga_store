local db = require("lapis.db")
local types = require("lapis.validate.types")
local Model = require("lapis.db.model").Model
local throw = require("common").error.throw

local ProductSales = Model:extend("product_sales", {
  relations = {
    { "sale",    belongs_to = "Sales" },
    { "product", belongs_to = "Products" },
  }
})

ProductSales.valid_record = types.params_shape{
  { "sale_id", types.db_id },
  { "product_id", types.db_id },
}

function ProductSales:new(params)
  local psale, err = self:create(params)
  if (not psale) then
    return throw("err_create_psale", err, params.sale_id, params.product_id)
  end

  return psale
end

function ProductSales:get(id)
  local psale = self:find{id = id}
  if (not psale) then
    return throw("err_get_psale", "ID not found", id)
  end

  return psale
end

function ProductSales:modify(id, params)
  local psale, gerr = self:get(id)
  if (not psale) then
    return gerr
  end

  local succ, err = psale:update(params)
  if (not succ) then
    return throw("err_modify_psale", err, id)
  end

  return psale
end

function ProductSales:delete(id)
  local psale, gerr = self:get(id)
  if (not psale) then
    return gerr
  end

  local succ = psale:delete()
  if (not succ) then
    return throw("err_delete_psale", "Failed to delete product sale", id)
  end

  return psale
end

function ProductSales:get_all()
  return self:select("order by id asc")
end

return ProductSales
