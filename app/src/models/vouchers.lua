local types = require("lapis.validate.types")
local Model = require("lapis.db.model").Model
local error = require("common").error
local errcode = error.code

local Vouchers = Model:extend("vouchers")

Vouchers.validate = error.make_validator {
  code = types.valid_text,
  discount = types.number,
}


function Vouchers:new(params)
  local vouch, err = self:create(params)
  if (not vouch) then
    return errcode.db_create("Failed to create voucher with code %s: %s", params.code, err)
  end

  return vouch
end

function Vouchers:get(id)
  local vouch = self:find{id = id}
  if (not vouch) then
    return errcode.db_select("Voucher with id %d not found", id)
  end

  return vouch
end

function Vouchers:modify(id, params)
  local vouch, gerr = self:get(id)
  if (not vouch) then
    return errcode.db_update(gerr)
  end

  local succ, err = vouch:update(params)
  if (not succ) then
    return errcode.db_update("Failed to update voucher with id %d: %s", id, err)
  end

  return vouch
end

function Vouchers:delete(id)
  local vouch, gerr = self:get(id)
  if (not vouch) then
    return errcode.db_delete(gerr)
  end

  local succ = vouch:delete()
  if (not succ) then
    return errcode.db_delete("Failed to delete voucher with id %d", id)
  end

  return vouch
end

function Vouchers:get_all()
  return self:select("order by code asc")
end

return Vouchers
