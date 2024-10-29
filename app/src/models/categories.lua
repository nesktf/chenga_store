local db = require("lapis.db")
local Model = require("lapis.db.model").Model

local Categories = Model:extend("categories", {
  relations = {
    { "product_categories", has_many = "ProductCategories" },
    { "discounts",          has_many = "Discounts" },
  }
})

return Categories
