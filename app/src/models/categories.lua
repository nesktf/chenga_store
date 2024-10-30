local db = require("lapis.db")
local types = require("lapis.validate.types")
local Model = require("lapis.db.model").Model
local throw = require("common").error.throw

local Categories = Model:extend("categories", {
  relations = {
    { "product_categories", has_many = "ProductCategories" },
    { "discounts",          has_many = "Discounts" },
  }
})

Categories.valid_record = types.params_shape{
  { "name", types.valid_text },
}

function Categories:new(params)
  local cat, err = self:create(params)
  if (not cat) then
    return throw("err_delete_category", err, params.name)
  end
  return cat
end

function Categories:get(name)
  local cat = self:find{ name = name }
  if (not cat) then
    return throw("err_get_category", "Name not found", name)
  end
  return cat
end

function Categories:modify(name, params)
  local cat, gerr = self:get(name)
  if (not cat) then
    return gerr
  end

  local succ, err = cat:update(params)
  if (not succ) then
    return throw("err_modify_category", err, name)
  end

  return cat
end

function Categories:delete(name)
  local cat, gerr = self:get(name)
  if (not cat) then
    return gerr
  end

  for _, prod in ipairs(self:get_product_categories()) do
    prod:update{
      category_id = db.NULL,
    }
  end

  for _, discount in ipairs(self:get_discounts()) do
    discount:delete()
  end

  local succ = cat:delete()
  if (not succ) then
    return throw("err_delete_category", "Failed to delete category", name)
  end

  return cat
end

function Categories:get_all()
  return self:select("order by name asc")
end

return Categories