local db = require("lapis.db")
local Model = require("lapis.db.model").Model

local Users = Model:extend("users", {
  relations = {
    { "sales", has_many = "Sales" }
  }
})

return Users

