local db = require("lapis.db")
local Model = require("lapis.db.model").Model

local Providers = Model:extend("providers", {
  relations = {
    { "products", has_many = "Products" },
  }
})

return Providers
