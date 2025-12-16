local u = require("util")
local cjson = require("cjson")
local Mangas = require("models.mangas")
local Users = require("models.users")
local SaleCart = require("models.sale_cart")
local errcode = u.errcode

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

local function fetch_manga_sales(csv_format)
  -- All sales for each product, ordered by sales total
  local mangas = u.assert(Mangas:get_all())

  local content = {}
  for _, manga in ipairs(mangas) do
    local sales = manga:get_sales()

    local sales_total = 0
    for _, sale in ipairs(sales) do
      local total = sale.price*sale.quantity
      if (sale.discount ~= 0) then
        total = total*(100-sale.discount)/100
      end
      sales_total = sales_total + total
    end
    if (csv_format) then
      table.insert(content, {
        manga.name,
        #sales,
        string.format("$%.2f", sales_total/100),
      })
    else
      table.insert(content, {
        name = manga.name,
        sales = #sales,
        total = sales_total / 100,
      })
    end
  end

  if (csv_format) then
    table.sort(content, function(lhs, rhs)
      return lhs[3] > rhs[3]
    end)
  else
    table.sort(content, function(lhs, rhs)
      return lhs.total > rhs.total
    end)
  end
  return content
end

local function fetch_month_sales()
  local sale_carts = SaleCart:get_all()
  local out = {}
  for i = 1, 12, 1 do
    table.insert(out, i, { total = 0 })
  end
  for _, sale in ipairs(sale_carts) do
    local month = u.assert(tonumber(os.date("%m", sale.sale_time)))
    out[month].total = out[month].total + sale.total
  end
  return out
end

local function fetch_client_stats(csv_format)
  -- All sales for each client, ordered by sales total
  local users = u.assert(Users:get_all())

  local content = {}
  for _, user in ipairs(users) do
    local sales = user:get_sale_carts()

    local sales_total = 0
    for _, sale in ipairs(sales) do
      sales_total = sales_total + sale.total
    end
    if (csv_format) then
      table.insert(content, {
        user.name,
        user.username,
        #sales,
        string.format("$%.2f",sales_total/100),
      })
    else
      table.insert(content, {
        name = user.name,
        username = user.username,
        sales = #sales,
        total = sales_total/100,
      })
    end
  end

  if (csv_format) then
    table.sort(content, function(lhs, rhs)
      return lhs[3] > rhs[3]
    end)
  else
    table.sort(content, function(lhs, rhs)
      return lhs.sales> rhs.sales
    end)
  end
  return content
end

local function setup(page)
  local function on_error(self)
    return {
      json = {
        ok = false,
        error = self.errors[1],
      }
    }
  end
  page:match("mangas", "/mangas", page.make_action {
    parse_json = true,
    on_error = on_error,
    GET = function(_)
      local out = fetch_manga_sales(false)
      return {
        json = {
          ok = true,
          mangas = #out == 0 and cjson.empty_array or out,
        }
      }
    end,
    POST = function(_)
      local content = fetch_manga_sales(true)

      local path = u.assert(table2csv(
        string.format("./data/reports/chenga_report_prod_%d.csv",
        os.time()),
        {
          header = { "Name", "TotalSales", "TotalMoney" },
          content = content,
          sep = ","
        }
      ))
      return {
        json = {
          ok = true,
          path = path:gsub("./data/", "/")
        }
      }
    end,
  })
  page:match("users", "/users", page.make_action {
    parse_json = true,
    on_error = on_error,
    GET = function(_)
      local out = fetch_client_stats(false)
      return {
        json = {
          ok = true,
          mangas = #out == 0 and cjson.empty_array or out,
        }
      }
    end,
    POST = function(_)
      local content = fetch_client_stats(true)
      local path = u.assert(table2csv(
        string.format("./data/reports/chenga_report_prod_%d.csv",
        os.time()),
        {
          header = { "Name", "Username", "TotalSales", "TotalMoney" },
          content = content,
          sep = ","
        }
      ))
      return {
        json = {
          ok = true,
          path = path:gsub("./data/", "/")
        }
      }
    end,
  })
  page:match("sales", "/sales", page.make_action {
    parse_json = true,
    on_error = on_error,
    GET = function(_)
      local out = fetch_month_sales()
      return {
        json = {
          ok = true,
          mangas = #out == 0 and cjson.empty_array or out,
        }
      }
    end,
  })
  return page
end

return {
  path = "/api/dashboard",
  name = "api.dashboard",
  setup = setup,
}
