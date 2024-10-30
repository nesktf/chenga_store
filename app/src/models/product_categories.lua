local db = require("lapis.db")
local types = require("lapis.validate.types")
local Model = require("lapis.db.model").Model
local throw = require("common").error.throw

local ProductCategories = Model:extend("product_categories", {
  relations = {
    { "category", belongs_to = "Categories" },
    { "product",  belongs_to = "Products" },
  }
})

ProductCategories.valid_record = types.params_shape{
  { "category_id", types.db_id },
  { "product_id", types.db_id },
}

function ProductCategories:new(params)
  local pcat, err = self:create(params)
  if (not pcat) then
    return throw("err_create_pcat", err, params.category_id, params.product_id)
  end

  return pcat
end

function ProductCategories:get(id)
  local pcat = self:find{id = id}
  if (not pcat) then
    return throw("err_get_pcat", "ID not found", id)
  end

  return pcat
end

function ProductCategories:modify(id, params)
  local pcat, gerr = self:get(id)
  if (not pcat) then
    return gerr
  end

  local succ, err = pcat:update(params)
  if (not succ) then
    return throw("err_modify_pcat", err, id)
  end

  return pcat
end

function ProductCategories:delete(id)
  local pcat, gerr = self:get(id)
  if (not pcat) then
    return gerr
  end

  local succ = pcat:delete()
  if (not succ) then
    return throw("err_delete_pcat", "Failed to delete product category", id)
  end

  return pcat
end

function ProductCategories:get_all()
  return self:select("order by id asc")
end

function ProductCategories:get_from_product(product_id)
  return self:select("where product_id = ?", product_id)
end

function ProductCategories:get_from_category(category_id)
  return self:select("where category_id = ?", category_id)
end

return ProductCategories
