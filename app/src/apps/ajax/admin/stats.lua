local lapis = require("common").lapis
local error = require("common").error
local errcode = error.code
local action = lapis.make_action()

local Mangas = require("models.mangas")
local Users = require("models.users")

local frag = {}

local function table2csv(path, params)
  local sep = params.sep or ','
  local file = io.open(path, 'w')
  if (not file) then
    return errcode.field_invalid("Invalid path %s", path)
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

function frag:client_report()
  -- All sales for each client, ordered by sales total
  local users = error.assert(Users:get_all())

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
  local path = error.assert(table2csv(string.format("./static/reports/chenga_report_client_%d.csv",
    os.time()),
    {
      header = { "Name", "Username", "TotalSales", "TotalMoney" },
      content = content,
      sep = ","
    }
  ))
  self.download_path = path

  return lapis.ajax_render("ajax.admin.stats")
end

function frag:product_report()
  -- All sales for each product, ordered by sales total
  local mangas = error.assert(Mangas:get_all())

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

  local path = error.assert(table2csv(string.format("./static/reports/chenga_report_prod_%d.csv",
    os.time()),
    {
      header = { "Name", "TotalSales", "TotalMoney" },
      content = content,
      sep = ","
    }
  ))
  self.download_path = path

  return lapis.ajax_render("ajax.admin.stats")
end


return lapis.make_ajax_action(frag)
