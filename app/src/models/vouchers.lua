local db = require("lapis.db")
local types = require("lapis.validate.types")
local Model = require("lapis.db.model").Model
local throw = require("common").error.throw

local Vouchers = Model:extend("vouchers")

Vouchers.valid_record = types.params_shape{
  { "value", types.number },
  { "code", types.valid_text },
}

function Vouchers:new(params)
  local vouch, err = self:create(params)
  if (not vouch) then
    return throw("err_create_vouch", err, params.code, params.value)
  end

  return vouch
end

function Vouchers:get(id)
  local vouch = self:find{id = id}
  if (not vouch) then
    return throw("err_get_vouch", "ID not found", id)
  end

  return vouch
end

function Vouchers:modify(id, params)
  local vouch, gerr = self:get(id)
  if (not vouch) then
    return gerr
  end

  local succ, err = vouch:update(params)
  if (not succ) then
    return throw("err_modify_vouch", err, id)
  end

  return vouch
end

function Vouchers:delete(id)
  local vouch, gerr = self:get(id)
  if (not vouch) then
    return gerr
  end

  local succ = vouch:delete()
  if (not succ) then
    return throw("err_delete_vouch", "Failed to delete voucher", id)
  end

  return vouch
end

return Vouchers
