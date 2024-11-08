local lapis = require("common").lapis
local error = require("common").error
local errcode = error.code
local action = lapis.make_action()

local Users = require("models.users")

local function frag_export(self)
  return lapis.ajax_render("ajax.admin.user_export")
end

local function frag_create(self)
  return lapis.ajax_render("ajax.admin.user_create")
end

local function frag_update(self)
  if (not self.params.id) then
    error.yield(errcode.field_invalid("Invalid field for update"))
  end

  local user = error.assert(Users:get_by_id(self.params.id))
  self.user = user

  return lapis.ajax_render("ajax.admin.user_update")
end

local function frag_delete(self)
  if (not self.params.id) then
    error.yield(errcode.field_invalid("Invalid field for delete"))
  end

  return lapis.ajax_render("ajax.admin.user_delete")
end


local function on_create(self)
  error.yield(errcode.field_invalid("create"))
end

local function on_update(self)
  self.error_title = "Update!!!"
  error.yield(errcode.field_invalid, "update")
end

local function on_delete(self)
  error.yield(errcode.field_invalid("delete"))
end

function action:POST()
  if (self.params.frag) then
    local frag = self.params.frag

    if (frag == "create") then
      return frag_create(self)
    end

    if (frag == "update") then
      return frag_update(self)
    end

    if (frag == "delete") then
      return frag_delete(self)
    end

    if (frag == "export") then
      return frag_export(self)
    end

    error.yield(errcode.field_invalid("Invalid fragment"))
  end

  if (self.params.req) then
    local req = self.params.req

    if (req == "create") then
      return on_create(self)
    end

    if (req == "update") then
      return on_update(self)
    end

    if (req == "delete") then
      return on_delete(self)
    end
  end

  error.yield(errcode.field_invalid("Invalid request"))
end

function action:on_error()
  return lapis.ajax_render("ajax.error")
end

return action
