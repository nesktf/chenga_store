local lapis = require("common").lapis
local error = require("common").error
local errcode = error.code
local Users = require("models.users")

local frag = {}

function frag:table_card()
  if (not self.params.crud_target) then
    error.yield(errcode.field_not_found, "table_card: No crud target provided")
  end
  local crud_target = self.params.crud_target

  if (not self.params.page_index) then
    error.yield(errcode.field_not_found, "table_card: No table index provided")
  end
  local page_index = tonumber(self.params.page_index)

  local max_users = 10
  local total_users = Users:count()

  self.ajax_action = "ajax.admin.users"
  self.crud_target = crud_target
  self.card_title = "User table"
  self.page_count = math.ceil(total_users/max_users)
  self.page_index = page_index
  self.col_names = { "Name", "E-Mail", "Username" }
  self.data_rows = (function()
    local out = {}

    local users = error.assert(Users:select("order by username asc limit ? offset ?",
      max_users, max_users*(page_index-1), {
      fields = "id,name,email,username"
    }))

    for _, field in ipairs(users) do
      table.insert(out, {
        form_id = field.id,
        content = { field.name, field.email, field.username }
      })
    end

    return out
  end)()

  return lapis.ajax_render("ajax.admin.table_card")
end

function frag:crud_delete()
  if (not self.params.id) then
    error.yield(errcode.field_invalid, "Invalid field for delete")
  end

  self.user = error.assert(Users:get_by_id(self.params.id))

  return lapis.ajax_render("ajax.admin.user_delete")
end

function frag:crud_update()
  if (not self.params.id) then
    error.yield(errcode.field_invalid, "Invalid field for update")
  end

  local user = error.assert(Users:get_by_id(self.params.id))
  self.user = user

  return lapis.ajax_render("ajax.admin.user_update")
end

function frag:crud_create()
  return lapis.ajax_render("ajax.admin.user_create")
end

function frag:crud_export()
  return lapis.ajax_render("ajax.admin.user_export")
end

function frag:crud_import()
  return lapis.ajax_render("ajax.admin.user_export")
end

function frag:create_status()
  local params = {
    name = self.params.name,
    address = self.params.address,
    email = self.params.email,
    username = self.params.username,
    password = self.params.password,
    is_admin = self.params.is_admin,
  }
  local _ = error.assert(Users:new(params))

  self.error_title = "Success!"
  self.errors = {
    {what="User created!", code=0}
  }
  return lapis.ajax_render("ajax.error")
end

function frag:update_status()
  local params = {
    name = self.params.name,
    address = self.params.address,
    email = self.params.email,
    username = self.params.username,
    is_admin = self.params.is_admin == "on" and true or false,
  }
  local _ = error.assert(Users:modify(self.params.username, params))
  self.error_title = "Success!"
  self.errors = {
    {what="User modified!", code=0}
  }
  return lapis.ajax_render("ajax.error")
end

function frag:delete_status()
  local _ = error.assert(Users:delete(self.params.username))

  self.error_title = "Success!"
  self.errors = {
    {what="User deleted!", code=0}
  }
  return lapis.ajax_render("ajax.error")
end


function frag:on_error()
  self.is_card = true
  return lapis.ajax_render("ajax.error")
end


return lapis.make_ajax_action(frag)
