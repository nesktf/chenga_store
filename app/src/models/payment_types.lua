local db = require("lapis.db")
local types = require("lapis.validate.types")
local Model = require("lapis.db.model").Model
local throw = require("common").error.throw

local PaymentTypes = Model:extend("payment_types", {
  relations = {
    { "sales", has_many = "Sales" },
  }
})

PaymentTypes.valid_record = types.params_shape{
  { "name", types.valid_text },
}

function PaymentTypes:new(params)
  local ptype, err = self:create(params)
  if (not ptype) then
    return throw("err_create_ptype", err, params.name)
  end
  return ptype
end

function PaymentTypes:get(name)
  local ptype = self:find{ name = name }
  if (not ptype) then
    return throw("err_get_ptype", "Name not found", name)
  end
  return ptype
end

function PaymentTypes:modify(name, params)
  local ptype, gerr = self:get(name)
  if (not ptype) then
    return gerr
  end

  local succ, err = ptype:update(params)
  if (not succ) then
    return throw("err_modify_ptype", err, name)
  end
  return ptype
end

function PaymentTypes:delete(name)
  local ptype, gerr = self:get(name)
  if (not ptype) then
    return gerr
  end

  for _, sale in ipairs(self:get_sales()) do
    sale:update{
      payment_type_id = db.NULL,
    }
  end

  local succ = ptype:delete()
  if (not succ) then
    return throw("err_delete_ptype", "Failed to delete payment type", name)
  end

  return ptype
end

function PaymentTypes:get_all()
  return self:select("order by name asc")
end

return PaymentTypes
