local u = require("util")
local errcode = u.errcode

local Mangas = require("models.mangas")

return {
  -- path = "/",
  name = "web",

  setup = function(page)
    page:match("index", "/", page.action{
      GET = function(self)
        return self:render("web.index")
      end
    })

    page:match("manga", "/manga/:id", page.action{
      GET = function(self)
        if (not self.params.id) then
          u.throw(u.errcode_fmt(errcode.field_not_found, "ID not provided"))
        end

        self.manga = Mangas:get(self.params.id)

        return self:render("web.manga")
      end,
    })

    page:match("search", "/search", page.action{
      GET = function(self)
        self.page_title = self:getstr("search")

        local mangas = Mangas:select([[
          where lower(name) like lower('%' || ? || '%') order by name asc limit ? offset ?
        ]], self.params.q, 10, 0)

        self.mangas = #mangas ~= 0 and mangas or nil

        return self:render("web.search")
      end
    })
    return page
  end,
}
