local types = require("lapis.validate.types")
local Model = require("lapis.db.model").Model
local error = require("common").error
local errcode = error.code

local Tags = Model:extend("tags", {
  relations = {
    { "manga_tags", has_many = "MangaTags" },
  }
})

Tags.validate = error.make_validator {
  name = types.valid_text,
}


function Tags:new(params)
  local tag, err = self:create(params)
  if (not tag) then
    return errcode.db_create("Failed to create tag '%s': %s", params.name, err)
  end

  return tag
end

function Tags:get(id)
  local tag = self:find{ id = id }
  if (not tag) then
    return errcode.db_select("Tag with id %d not found", id)
  end

  return tag
end

function Tags:modify(id, params)
  local tag, gerr = self:get(id)
  if (not tag) then
    return errcode.db_update(gerr)
  end

  local succ, err = tag:update(params)
  if (not succ) then
    return errcode.db_update("Failed to update tag with id %d: %s", id, err)
  end

  return tag
end

function Tags:delete(id)
  local tag, gerr = self:get(id)
  if (not tag) then
    return errcode.db_delete(gerr)
  end

  for _, mtag in ipairs(self:get_manga_tags()) do
    mtag:delete()
  end

  local succ = tag:delete()
  if (not succ) then
    return errcode.db_delete("Failed to delete tag with id %d", id)
  end

  return tag
end

function Tags:get_all()
  return self:select("order by name asc")
end

return Tags
