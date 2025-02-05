local md5 = require("md5")
local u = require("util")
local errcode = u.errcode

local Users = require("models.users")
local Mangas = require("models.mangas")

local function table2csv(path, params)
  local sep = params.sep or ','
  local file = io.open(path, 'w')
  if (not file) then
    return nil, u.errcode_fmt(errcode.field_invalid, "Invalid path '%s'", path)
  end

  file:write((function()
    local out = ""
    for i=1,#params.header do
      if (i ~= #params.header) then
        out = out..params.header[i]..sep
      else
        out = out..params.header[i]
      end
    end
    return out
  end)())
  file:write("\n")

  for _, item in ipairs(params.content) do
    file:write((function()
      local out = ""
      for i=1,#item do
        if (i ~= #item) then
          out = out..item[i]..sep
        else
          out = out..item[i]
        end
      end
      return out
    end)())
    file:write("\n")
  end

  file:close()

  return path
end

return {
  path = "/ajax/admin",
  name = "ajax.admin",

  setup = function(page)
    page:match("users", "/users", page.action{
      on_error = function(self)
        self.is_card = true
        return self:render("ajax.error")
      end,

      delete_status = function(self)
        local _ = u.assert(Users:delete(self.params.username))

        self.error_title = "Success!"
        self.errors = {
          {what="User deleted!", status=0}
        }
        return self:render("ajax.error")
      end,

      update_status = function(self)
        local params = {
          name = self.params.name,
          address = self.params.address,
          email = self.params.email,
          username = self.params.username,
          is_admin = self.params.is_admin == "on" and true or false,
        }
        local _ = u.assert(Users:modify(self.params.username, params))
        self.error_title = "Success!"
        self.errors = {
          {what="User modified!", status=0}
        }
        return self:render("ajax.error")
      end,

      create_status = function(self)
        local params = {
          name = self.params.name,
          address = self.params.address,
          email = self.params.email,
          username = self.params.username,
          password = self.params.password,
          is_admin = self.params.is_admin,
        }
        local _ = u.assert(Users:new(params))

        self.error_title = "Success!"
        self.errors = {
          {what="User created!", status=0}
        }
        return self:render("ajax.error")
      end,

      crud_create = function(self)
        return self:render("ajax.admin.user_create")
      end,

      crud_delete = function(self)
        if (not self.params.id) then
          u.throw(u.errcode_fmt(errcode.field_invalid,
            "Invalid field for delete"))
        end

        self.user = u.assert(Users:get_by_id(self.params.id))
        return self:render("ajax.admin.user_delete")
      end,

      crud_update = function(self)
        if (not self.params.id) then
          u.throw(u.errcode_fmt(errcode.field_invalid,
            "Invalid field for update"))
        end

        local user = u.assert(Users:get_by_id(self.params.id))
        self.user = user
        return self:render("ajax.admin.user_update")
      end,

      crud_export = function(self)
        return self:render("ajax.admin.user_export")
      end,

      crud_import = function(self)
        return self:render("ajax.admin.user_export")
      end,

      table_card = function(self)
        if (not self.params.crud_target) then
          u.throw(u.errcode_fmt(errcode.field_not_found,
            "table_card: No crud target provided"))
        end
        local crud_target = self.params.crud_target

        if (not self.params.page_index) then
          u.throw(u.errcode_fmt(errcode.field_not_found,
            "table_card: No table index provided"))
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

          local users = u.assert(Users:select("order by username asc limit ? offset ?",
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
        return self:render("ajax.admin.table_card")
      end,
    })

    page:match("manga", "/manga", page.action{
      on_error = function(self)
        return self:render("ajax.error")
      end,
      
      delete_status = function(self)
        local _ = u.assert(Mangas:delete(self.params.manga_id))

        self.error_title = "Success"
        self.errors = {
          { what = "Product deleted!", code = 0 }
        }

        return self:render("ajax.error")
      end,

      update_status = function(self)
        local params = {
          name = self.params.name,
          author = self.params.author,
          isbn = self.params.isbn,
          stock = self.params.stock,
          price = self.params.price,
        }

        local _ = u.assert(Mangas:modify(self.params.manga_id, params))
        self.error_title = "Success"
        self.errors = {
          { what = "Product modified!", code = 0} 
        }

        return self:render("ajax.error")
      end,

      create_status = function(self)
        local image_path = u.assert((function(image)
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

        local status, merr = Mangas:new(params)

        if (not status) then
          os.remove(image_path)
          u.throw(merr)
        end

        self.error_title = "Success"
        self.errors = {
          { what = "Product uploaded!", code = 0 }
        }

        return self:render("ajax.error")
      end,

      crud_delete = function(self)
        if (not self.params.id) then
          u.throw(u.errcode_fmt(errcode.field_not_found,
            "No id parameter"))
        end

        self.manga = u.assert(Mangas:get(self.params.id))
        return self:render("ajax.admin.manga_delete")
      end,

      crud_update = function(self)
        if (not self.params.id) then
          u.throw(u.errcode_fmt(errcode.field_not_found,
            "No id parameter"))
        end

        self.manga = u.assert(Mangas:get(self.params.id))
        return self:render("ajax.admin.manga_update")
      end,

      crud_create = function(self)
        return self:render("ajax.admin.manga_create")
      end,

      table_card = function(self)
        if (not self.params.crud_target) then
          u.throw(u.errcode_fmt(errcode.field_not_found,
            "table_card: No crud target provided"))
        end
        local crud_target = self.params.crud_target

        if (not self.params.page_index) then
          u.throw(u.errcode_fmt(errcode.field_not_found,
            "table_card: No table index provided"))
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

          local manga = u.assert(Mangas:select("order by name asc limit ? offset ?", 
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

        return self:render("ajax.admin.table_card")
      end,
    })

    page:match("stats", "/stats", page.action{
      client_report = function(self)
        -- All sales for each client, ordered by sales total
        local users = u.assert(Users:get_all())

        self.req_type = "users"
        local content = {}
        for _, user in ipairs(users) do
          local sales = user:get_sales()

          local sales_total = 0
          for _, sale in ipairs(sales) do
            sales_total = sales_total + sale.total
          end
          table.insert(content, {
            user.name,
            user.username,
            #sales,
            string.format("$%.2f",sales_total/100),
          })
        end

        table.sort(content, function(lhs, rhs)
          return lhs[3] > rhs[3]
        end)
        self.content = content
        local path = u.assert(table2csv(
          string.format("./static/reports/chenga_report_client_%d.csv",
          os.time()),
          {
            header = { "Name", "Username", "TotalSales", "TotalMoney" },
            content = content,
            sep = ","
          }
        ))
        self.download_path = path

        return self:render("ajax.admin.stats")
      end,

      product_report = function(self)
        -- All sales for each product, ordered by sales total
        local mangas = u.assert(Mangas:get_all())

        self.req_type = "products"
        local content = {}

        for _, manga in ipairs(mangas) do
          local sales = manga:get_sales()

          local sales_total = 0
          for _, sale in ipairs(sales) do
            sales_total = sales_total + sale.total
          end
          table.insert(content, {
            manga.name,
            #sales,
            string.format("$%.2f", sales_total/100),
          })
        end

        table.sort(content, function(lhs, rhs)
          return lhs[3] > rhs[3]
        end)
        self.content = content

        local path = u.assert(table2csv(
          string.format("./static/reports/chenga_report_prod_%d.csv",
          os.time()),
          {
            header = { "Name", "TotalSales", "TotalMoney" },
            content = content,
            sep = ","
          }
        ))
        self.download_path = path

        return self:render("ajax.admin.stats")
      end,
    })
    return page
  end,
}
