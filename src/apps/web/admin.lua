local Users = require("models.users")
local Mangas = require("models.mangas")
local Sales = require("models.sales")
local Tags = require("models.tags")

local function retrieve_stats(_)
  local stats = {}

  stats.user_count = Users:count()
  stats.admin_count = Users:count("is_admin")

  stats.prod_count = Mangas:count()
  stats.tag_count = Tags:count()

  local sales = Sales:count()
  if (sales == 0) then
    stats.sales_count = "0 :("
  else
    stats.sales_count = sales
  end

  -- local moni = Sales:get_total()
  local moni = 0
  if (moni == 0) then
    stats.sales_total = "0 :("
  else
    stats.sales_total = string.format("$%.2f", moni/100)
  end

  return stats
end

return {
  name = "web.admin",
  path = "/admin",

  setup = function(page)
    page:match("index", "", page.action{
      before = function(self)
        self.page_title = self:getstr("admin")
      end,
      GET = function(self)
        if (not self.session.user) then
          return self:redirect_to("web.user.login")
        end

        self.stats = retrieve_stats(self)

        return self:render("web.admin.index")
      end,
    })
    page:match("manga", "/manga", page.action{
      GET = function(self)
        return self:render("web.admin.manga")
      end,
    })
    page:match("users", "/users", page.action{
      GET = function(self)
        return self:render("web.admin.users")
      end,
    })
    return page
  end
}
