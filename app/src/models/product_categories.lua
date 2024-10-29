local db = require("lapis.db")
local Model = require("lapis.db.model").Model

local ProductCategories = Model:extend("product_categories", {
  relations = {
    { "category", belongs_to = "Categories" },
    { "product",  belongs_to = "Products" },
  }
})

return ProductCategories
