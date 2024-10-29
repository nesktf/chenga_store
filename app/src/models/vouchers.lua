local db = require("lapis.db")
local Model = require("lapis.db.model").Model

local Vouchers = Model:extend("vouchers")

return Vouchers
