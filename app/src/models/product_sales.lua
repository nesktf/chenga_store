local db = require("lapis.db")
local Model = require("lapis.db.model").Model

local ProductSales = Model:extend("product_sales", {
  relations = {
    { "sale",    belongs_to = "Sales" },
    { "product", belongs_to = "Products" },
  }
})

return ProductSales
