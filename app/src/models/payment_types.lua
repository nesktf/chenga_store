local db = require("lapis.db")
local Model = require("lapis.db.model").Model

local PaymentTypes = Model:extend("payment_types", {
  relations = {
    { "sales", has_many = "Sales" },
  }
})

return PaymentTypes
