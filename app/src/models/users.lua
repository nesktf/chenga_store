local db = require("lapis.db")
local types = require("lapis.validate.types")
local Model = require("lapis.db.model").Model
local throw = require("common").error.throw

local Users = Model:extend("users", {
  relations = {
    { "sales", has_many = "Sales" }
  }
})

Users.valid_record = types.params_shape{
  { "name", types.valid_text },
  { "address", types.valid_text },
  { "email", types.valid_text }, -- TODO: Check email
  { "username", types.valid_text },
  { "password", types.valid_text },
}

function Users:new(params)
  local user, err = self:create(params)
  if (not user) then
    return throw("err_create_user", err, params.username)
  end

  return user
end

function Users:get(username)
  local user = self:find{ username = username }
  if (not user) then
    return throw("err_get_user", "Username not found", username)
  end

  return user
end

function Users:modify(username, params)
  local user, gerr = self:get(username)
  if (not user) then
    return gerr
  end

  local success, err = user:update(params)
  if (not success) then
    return throw("err_modify_user", err, username)
  end

  return user
end

function Users:delete(username)
  local user, gerr = self:get(username)
  if (not user) then
    return gerr
  end

  for _, sale in ipairs(user:get_sales()) do
    sale:update({
      user_id = db.NULL,
    })
  end

  local success = user:delete()
  if (not success) then
    return throw("err_delete_user", "Failed to delete user", username)
  end
  return user
end

function Users:get_all()
  return self:select("order by username asc")
end

return Users
