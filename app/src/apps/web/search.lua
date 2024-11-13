local lapis = require("common").lapis
local action = lapis.make_action()

local Mangas = require("models.mangas")

local function populate_products(param, limit, offset)
  local mangas = Mangas:select([[
    where lower(name) like lower('%' || ? || '%') order by name asc limit ? offset ?
  ]], param, limit, offset)
  if (#mangas == 0) then
    return nil
  end

  return mangas
end

function action:GET()
  self.page_title = self:getstr("search")

  self.mangas = populate_products(self.params.q, 10, 0)

  return { render = "web.search" }
end

return action
