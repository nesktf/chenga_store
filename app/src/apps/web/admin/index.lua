local lapis = require("common").lapis
local error = require("common").error
local action = lapis.make_action()

local Users = require("models.users")
local Mangas = require("models.mangas")
local Sales = require("models.sales")
local Tags = require("models.tags")

function retrieve_stats(self)
  local stats = {}

  stats.user_count = Users:count()
  stats.admin_count = Users:count("is_admin")

  stats.prod_count = Mangas:count()
  stats.tag_count = Tags:count()

  stats.sales_count = Sales:count()
  stats.sales_total = Sales:get_total()

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
