local db = require("lapis.db")
local Model = require("lapis.db.model").Model

local Products = Model:extend("products", {
  relations = {
    { "product_categories", has_many = "ProductCategories" },
    { "product_sales",      has_many = "ProductSales" },

    { "provider",           belongs_to = "Providers" },
  }
})

return Products
