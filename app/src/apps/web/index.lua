local u = require("util")
local errcode = u.errcode

local Mangas = require("models.mangas")
local UserFavs = require("models.user_favs")
local Users = require("models.users")
local CartItems = require("models.cart_items")

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
        self.mark_fav = false
        if (self.session.user) then
          local user = u.assert(Users:get(self.session.user.username))
          local cart = user:get_user_cart()
          local ufav = UserFavs:find_favorite(user.id, self.params.id)
          if (ufav) then
            self.mark_fav = true
          end

          local item = CartItems:find({
            user_cart_id = cart.id,
            manga_id = self.manga.id,
          })
          if (item) then
            self.manga.stock = self.manga.stock - item.quantity
          end
        end

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
