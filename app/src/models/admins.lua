local db = require("lapis.db")
local types = require("lapis.validate.types")
local Model = require("lapis.db.model").Model
local throw = require("common").error.throw

local Admins = Model:extend("admins")

Admins.valid_record = types.params_shape{
  { "username", types.valid_text },
  { "password", types.valid_text },
}

function Admins:new(params)
  local admin, err = self:create(params)
  if (not admin) then
    return throw("err_create_admin", err, params.username)
  end
  return admin
end

function Admins:get(username)
  local admin = self:find{ username = username }
  if (not admin) then
    return throw("err_get_admin", "Username not found", username)
  end
  return admin
end

function Admins:modify(username, params)
  local admin, gerr = self:get(username)
  if (not admin) then
    return gerr
  end

  local success, err = admin:update(params)
  if (not success) then
    return throw("err_modify_admin", {err, username})
  end

  return admin
end

function Admins:delete(username)
  local admin, gerr = self:get(username)
  if (not admin) then
    return gerr
  end

  local success = admin:delete()
  if (not success) then
    return throw("err_delete_admin", "Failed to delete user", username)
  end
  return admin
end

function Admins:get_all()
  return self:select("order by username asc")
end

return Admins
