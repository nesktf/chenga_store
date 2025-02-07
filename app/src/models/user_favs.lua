local types = require("lapis.validate.types")
local Model = require("lapis.db.model").Model
local u = require("util")
local errcode = u.errcode

local UserFavs = Model:extend("user_favs", {
  relations = {
    { "user", belongs_to = "Users" },
    { "manga", belongs_to = "Mangas" },
  }
})

UserFavs.validate = u.make_validator {
  user_id = types.db_id,
  manga_id = types.db_id,
}

function UserFavs:new(params)
  local ufav, err = self:create(params)
  if (not ufav) then
    return nil, u.errcode_fmt(errcode.db_create,
      "Failed to create user fav: %s", err
    )
  end
  return ufav
end

function UserFavs:get(id)
  local ufav = self:find{id = id}
  if (not ufav) then
    return nil, u.errcode_fmt(errcode.db_select,
      "User favorite with id %d not found", id
    )
  end
  return ufav
end

function UserFavs:modify(id, params)
  local ufav, gerr = self:get(id)
  if (not ufav) then
    return nil, gerr
  end

  local succ, err = ufav:update(params)
  if (not succ) then
    return nil, u.errcode_fmt(errcode.db_update,
      "Failed to update user favorite with id %d: %s", id, err
    )
  end

  return ufav
end

function UserFavs:delete(id)
  local ufav, gerr = self:get(id)
  if (not ufav) then
    return nil, gerr
  end

  local succ = ufav:delete()
  if (not succ) then
    return nil, u.errcode_fmt(errcode.db_delete,
      "Failed to delete user fav with id %d", id
    )
  end
  return ufav
end

function UserFavs:get_all()
  return self:select("order by user_id desc")
end

return UserFavs
