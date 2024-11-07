local types = require("lapis.validate.types")
local Model = require("lapis.db.model").Model
local error = require("common").error
local errcode = error.code

local MangaTags = Model:extend("manga_tags", {
  relations = {
    { "manga", belongs_to = "Mangas" },
    { "tag", belongs_to = "Tags" },
  }
})

MangaTags.validate = error.make_validator {
  manga_id = types.db_id,
  tag_id = types.db_id,
}

function MangaTags:new(params)
  local mtag, err = self:create(params)
  if (not mtag) then
    return errcode.db_create("Failed to add tag for manga %d: %s", params.manga_id, err)
  end

  return mtag
end

function MangaTags:get(id)
  local mtag = self:find{ id = id }
  if (not mtag) then
    return errcode.db_select("Manga tag with id %d not found", id)
  end

  return mtag
end

function MangaTags:modify(id, params)
  local mtag, gerr = self:get(id)
  if (not mtag) then
    return errcode.db_update(gerr)
  end

  local succ, err = mtag:update(params)
  if (not succ) then
    return errcode.db_update("Failed to update manga tag with id %d: %s", id, err)
  end

  return mtag
end

function MangaTags:delete(id)
  local mtag, gerr = self:get(id)
  if (not mtag) then
    return errcode.db_delete(gerr)
  end

  local succ = mtag:delete()
  if (not succ) then
    return errcode.db_delete("Failed to delete manga tag with id %d", id)
  end

  return mtag
end

function MangaTags:get_all()
  return self:select("order by id asc")
end

return MangaTags
