local db = require("lapis.db")
local types = require("lapis.validate.types")
local Model = require("lapis.db.model").Model
local throw = require("common").error.throw

local Products = Model:extend("products", {
  relations = {
    { "product_categories", has_many = "ProductCategories" },
    { "product_sales",      has_many = "ProductSales" },

    { "provider",           belongs_to = "Providers" },
  }
})

Products.valid_record = types.params_shape {
  { "name", types.valid_text },
  { "price", types.number },
  -- { "date_appended", types.date },
  { "stock", types.number },
  { "provider_id", types.db_id },
}

function Products:new(params)
  params.date_appended = params.date_appended or db.format_date()
  local prod, err = self:create(params)
  if (not prod) then
    return throw("err_create_prod", err, params.name, params.provider_id)
  end

  return prod
end

function Products:get(id)
  local prod = self:find{id = id}
  if (not prod) then
    return throw("err_get_prod", "ID not found", id)
  end

  return prod
end

function Products:modify(id, params)
  local prod, gerr = self:get(id)
  if (not prod) then
    return gerr
  end

  local succ, err = prod:update(params)
  if (not succ) then
    return throw("err_modify_prod", err, id)
  end

  return prod
end

function Products:delete(id)
  local prod, gerr = self:get(id)
  if (not prod) then
    return gerr
  end

  for _, psale in ipairs(self:get_product_sales()) do
    psale:delete()
  end
  
  for _, pcat in ipairs(self:get_product_categories()) do
    pcat:delete()
  end

  local succ = prod:delete()
  if (not succ) then
    return throw("err_delete_prod", "Failed to delete product")
  end

  return prod
end

function Products:get_all()
  return self:select("order by name asc")
end

function Products:validate(params)
  return true
end

return Products
