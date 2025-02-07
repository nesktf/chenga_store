local types = require("lapis.validate.types")
local Model = require("lapis.db.model").Model
local error = require("util")
local errcode = error.errcode

local Mangas = Model:extend("mangas", {
  relations = {
    { "cart_items", has_many = "CartItems" },
    { "manga_tags", has_many = "MangaTags" },
    { "sales", has_many = "Sales" },
    { "user_favs", has_many = "UserFavs" },
  }
})

Mangas.validate = error.make_validator {
  name = types.valid_text,
  authot = types.valid_text,
  isbn = types.custom(function(val)
    if (val == nil) then
      return true -- Is an optional parameter
    end

    if (type(val) ~= "string") then
      return nil, "ISBN is not a string"
    end

    if (string.len(val) ~= 13) then
      return nil, "Invalid ISBN length"
    end

    local starts_with = string.sub(val, 1, 3)
    if (starts_with ~= "978" or starts_with ~= "979") then
      return nil, "Invalid ISBN"
    end

    -- Add more checks here...

    return true
  end),
  stock = types.integer,
  price = types.number,
  image_path = types.string:is_optional(),
}


function Mangas:new(params)
  local manga, err = self:create(params)
  if (not manga) then
    return nil, error.errcode_fmt(errcode.db_create,
      "Failed to create manga '%s': %s", params.name, err
    )
  end

  return manga
end

function Mangas:get(id)
  local manga = self:find{id = id}
  if (not manga) then
    return nil, error.errcode_fmt(errcode.db_select,
      "Manga with id %d not found", id
    )
  end

  return manga
end

function Mangas:modify(id, params)
  local manga, gerr = self:get(id)
  if (not manga) then
    return nil, gerr
  end

  local succ, err = manga:update(params)
  if (not succ) then
    return nil, error.errcode_fmt(errcode.db_update,
      "Failed to update manga with id %d: %s", id, err
    )
  end

  return manga
end

function Mangas:delete(id)
  local manga, gerr = self:get(id)
  if (not manga) then
    return nil, gerr
  end

  for _, item in ipairs(manga:get_cart_items()) do
    item:delete()
  end

  for _, mtag in ipairs(manga:get_manga_tags()) do
    mtag:delete()
  end

  local succ = manga:delete()
  if (not succ) then
    return nil, error.errcode_fmt(errcode.db_delete,
      "Failed to delete manga with id %d", id
    )
  end

  return manga
end

function Mangas:get_all()
  return self:select("order by name asc")
end

return Mangas
