-- local db = require("lapis.db")
local types = require("lapis.validate.types")
local Model = require("lapis.db.model").Model
local u = require("util")
local errcode = u.errcode
local bcrypt = require("bcrypt")
local secret = u.config.secret

local UserCarts = require("models.user_carts")

local Users = Model:extend("users", {
  relations = {
    { "user_cart", has_one = "UserCarts" },
    { "sale_carts", has_many = "SaleCart", order = "sale_time desc" },
    { "user_favs", has_many = "UserFavs" }
  }
})

Users.validate = u.make_validator {
  name = types.valid_text,
  address = types.valid_text,
  email = types.custom(function(val)
    if (not val) then
      return nil, "can't be null"
    end

    if (type(val) ~= "string") then
      return nil, "not a string"
    end

    -- TODO: Add email regex here...

    return true
  end),
  username = types.valid_text,
  password = types.limited_text(32, 8),
  is_admin = types.boolean,
}


function Users:new(params)
  if (not params.username or not params.password) then
    return nil, u.errcode_fmt(errcode.db_create,
      "Failed to create user, invalid login parameters"
    )
  end

  local prehash = params.username:lower()..params.password..secret
  params.password = bcrypt.digest(prehash, 12)

  local user, err = self:create(params)
  if (not user) then
    return nil, u.errcode_fmt(errcode.db_create,
      "Failed to create user '%s': %s", params.username, err
    )
  end

  local cart, cerr = UserCarts:new {
    subtotal = 0,
    -- discount = 0,
    -- total = 0,
    user_id = user.id
  }
  if (not cart )then
    -- return errcode.db_create("Failed to create cart for user %s: %s", params.username, cerr)
    return nil, cerr
  end

  return user
end

function Users:get(username)
  local user = self:find{ username = username }
  if (not user) then
    return nil, u.errcode_fmt(errcode.db_select,
      "Username '%s' not found", username
    )
  end

  return user
end

function Users:get_by_id(id)
  local user = self:find{ id = id }
  if (not user) then
    return nil, u.errcode_fmt(errcode.db_select,
      "Username with id '%d' not found", id
    )
  end

  return user
end

function Users:modify(username, params)
  local user, gerr = self:get(username)
  if (not user) then
    return nil, gerr
  end

  local success, err = user:update(params)
  if (not success) then
    return nil, u.errcode_fmt(errcode.db_update,
      "Error updating user '%s': %s", username, err
    )
  end

  return user
end

function Users:delete(username)
  local user, gerr = self:get(username)
  if (not user) then
    return nil, gerr
  end

  user:get_user_cart():delete()
  user:get_user_favs():delete()
  user:get_sale_cart():delete()
  -- for _, item in ipairs(user:get_cart_items()) do
  --   item:delete()
  -- end

  -- for _, sale in ipairs(user:get_sales()) do
  --   sale:update({
  --     user_id = db.NULL,
  --   })
  -- end

  local success = user:delete()
  if (not success) then
    return nil, u.errcode_fmt(errcode.db_delete,
      "Error deleting user '%s'", username
    )
  end
  return user
end

function Users:get_all()
  return self:select("order by username asc")
end

function Users:is_admin(username)
  local user = self:get(username)
  return user and user.is_admin or false
end

function Users:login(params)
  if (not params.username or not params.password) then
    return nil, u.errcode_fmt(errcode.field_invalid,
      "Invalid parameters"
    )
  end

  local user = self:get(params.username)
  if (not user) then
    return nil, u.errcode_fmt(errcode.invalid_auth,
      "Invalid user '%s'", params.username
    )
  end

  local prehash
  if (user.username == "cirno" or user.username == "marisa" or user.username == "nitori") then
    prehash = "admin"..params.password..secret
  else
    prehash = user.username:lower()..params.password..secret
  end
  if (not bcrypt.verify(prehash, user.password)) then
    return nil, u.errcode_fmt(errcode.password_not_match,
      "Invalid password"
    )
  end

  return user
end

return Users
