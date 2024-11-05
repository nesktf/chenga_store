local db = require("lapis.db")
local types = require("lapis.validate.types")
local Model = require("lapis.db.model").Model
local throw = require("common").error.throw

local Providers = Model:extend("providers", {
  relations = {
    { "products", has_many = "Products" },
  }
})

Providers.valid_record = types.params_shape{
  { "name", types.valid_text },
  { "address", types.valid_text },
  { "email", types.valid_text }, -- TODO verify email
  { "cuit", types.valid_text }, -- TODO verifty cuit
}

function Providers:new(params)
  local prov, err = self:create(params)
  if (not prov) then
    return throw("err_create_prov", err, params.name, params.cuit)
  end

  return prov
end

function Providers:get(id)
  local prov = self:find{id = id}
  if (not prov) then
    return throw("err_get_prov", "ID not found", id)
  end
  
  return prov
end

function Providers:modify(id, params)
  local prov, gerr = self:get(id)
  if (not prov) then
    return gerr
  end

  local succ, err = prov:update(params)
  if (not succ) then
    return throw("err_modify_prov", err, id)
  end

  return prov
end

function Providers:delete(id)
  local prov, gerr = self:get(id)
  if (not prov) then
    return gerr
  end

  local succ = prov:delete()
  if (not succ) then
    return throw("err_delete_prov", "Failed to delete provider")
  end

  return prov
end

function Providers:get_all()
  return self:select("order by name asc")
end

function Providers:validate(params)
  -- TODO: validate lol
  return true
end

return Providers
