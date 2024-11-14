local lapis = require("common").lapis
local error = require("common").error
local errcode = error.code
local md5 = require("md5")
local Mangas = require("models.mangas")

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

  local max_manga = 10
  local total_manga = Mangas:count()

  self.ajax_action = "ajax.admin.manga"
  self.crud_target = crud_target
  self.card_title = "Product table"
  self.page_count = math.ceil(total_manga/max_manga)
  self.page_index = page_index
  self.col_names = { "Name", "ISBN", "Stock", "Price" }
  self.data_rows = (function()
    local out = {}

    local manga = error.assert(Mangas:select("order by name asc limit ? offset ?", 
      max_manga, max_manga*(page_index-1), {
      fields = "id,name,isbn,stock,price",
    }))

    for _,field in ipairs(manga) do
      table.insert(out, {
        form_id = field.id,
        content = { field.name, field.isbn == "" and "N/A" or field.isbn, field.stock, 
          string.format("$%.2f", field.price/100) }
      })
    end

    return out
  end)()

  return lapis.ajax_render("ajax.admin.table_card")
end

function frag:crud_create()
  return lapis.ajax_render("ajax.admin.manga_create")
end

function frag:crud_update()
  if (not self.params.id) then
    error.yield(errcode.field_not_found, "No id parameter")
  end

  self.manga = error.assert(Mangas:get(self.params.id))
  return lapis.ajax_render("ajax.admin.manga_update")
end

function frag:crud_delete()
  if (not self.params.id) then
    error.yield(errcode.field_not_found, "No id parameter")
  end

  self.manga = error.assert(Mangas:get(self.params.id))
  return lapis.ajax_render("ajax.admin.manga_delete")
end

function frag:create_status()
  local image_path = error.assert((function(image)
    local function file_exists(path)
      local f = io.open(path, 'r')
      return f ~= nil and io.close(f)
    end

    if (not image) then
      return errcode.field_not_found("No manga image provided")
    end

    local hash = md5.sumhexa(image.content)
    local ext = image.filename:match("^.+(%..+)$")

    local path = string.format("./static/image/%s%s", hash, ext)
    if (file_exists(path)) then
      return path -- Reuse image if hash matches
    end

    local file = io.open(path, 'w')
    if (not file) then
      return errcode.db_create("Failed to open image file")
    end

    file:write(image.content)
    file:close()

    return path
  end)(self.params.manga_image))

  local params = {
    name = self.params.name,
    author = self.params.author,
    isbn = self.params.isbn,
    stock = self.params.stock,
    price = self.params.price,
    image_path = image_path,
  }

  local status, err = Mangas:new(params)

  if (not status) then
    os.remove(image_path)
    error.yield(err)
  end

  self.error_title = "Success"
  self.errors = {
    { what = "Product uploaded!", code = 0 }
  }
  return lapis.ajax_render("ajax.error")
end

function frag:update_status()
  local params = {
    name = self.params.name,
    author = self.params.author,
    isbn = self.params.isbn,
    stock = self.params.stock,
    price = self.params.price,
  }

  local _ = error.assert(Mangas:modify(self.params.manga_id, params))
  self.error_title = "Success"
  self.errors = {
    { what = "Product modified!", code = 0} 
  }
  return lapis.ajax_render("ajax.error")
end

function frag:delete_status()
  local _ = error.assert(Mangas:delete(self.params.manga_id))

  self.error_title = "Success"
  self.errors = {
    { what = "Product deleted!", code = 0 }
  }

  return lapis.ajax_render("ajax.error")
end

function frag:on_error()
  return lapis.ajax_render("ajax.error")
end

return lapis.make_ajax_action(frag)
