local lapis = require("common").lapis
local error = require("common").error
local action = lapis.make_action()

local Users = require("models.users")
local Mangas = require("models.mangas")
local Sales = require("models.sales")
local Tags = require("models.tags")

local function retrieve_stats(self)
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

  local moni = Sales:get_total()
  if (moni == 0) then
    stats.sales_total = "0 :("
  else
    stats.sales_total = moni
  end

  return stats
end

function action:before()
  self.page_title = self:getstr("admin")
end

function action:GET()
  if (not self.session.user) then
    return { redirect_to = self:url_for('web.user.login') }
  end

  self.stats = retrieve_stats(self)

  return { render = "web.admin.index" }
end

return action
