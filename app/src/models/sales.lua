local db = require("lapis.db")
local Model = require("lapis.db.model").Model

local Sales = Model:extend("sales", {
  relations = {
    { "product_sales",  has_many = "ProductSales" },

    { "user",           belongs_to = "Users" },
    { "payment_type",   belongs_to = "PaymentTypes" },
  }
})

return Sales
