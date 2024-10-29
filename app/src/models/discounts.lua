local db = require("lapis.db")
local Model = require("lapis.db.model").Model

local Discounts = Model:extend("discounts", {
  relations = {
    { "category", belongs_to = "Categories" },
  }
})

return Discounts
