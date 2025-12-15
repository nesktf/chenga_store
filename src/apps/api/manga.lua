local u = require("util")
local cjson = require("cjson")
local Mangas = require("models.mangas")

local function price_fmt(price)
  return string.format("$%.2f", price*0.01)
end

return {
  path = "/api/manga",
  name = "api.manga",

  setup = function(page)
    page:match("count", "/count", page.make_action{
      parse_json = true,
      GET = function(self)
        return self:render_json({
          count = Mangas:count(),
        })
      end,
    })
    page:match("index", "/index", page.make_action {
      parse_json = true,
      before = function(self)
        u.assert(self.params.order, u.errcode_fmt(u.errcode.field_not_found, "No order proivded"))
        u.assert((function()
          local order = self.params.order
          return order == "asc" or order == "desc" or order == "rand"
        end)(), u.errcode_fmt(u.errcode.field_invalid, "Invalid order"))

        if (self.params.limit) then
          u.assert(self.params.page, u.errcode_fmt(u.errcode.field_not_found, "No page provided"))
          -- local count = Mangas:count()
          -- u.assert(self.params.limit <= count, u.errcode_fmt(u.errcode.field_invalid,
          --   "Invalid page size"))
          -- local pages = math.ceil(count / self.params.limit)
          -- u.assert(self.params.page < pages,
          --   u.errcode_fmt(u.errcode.field_invalid, "Invalid page %d", pages))
        end
      end,
      GET = function(self)
        local order
        if (self.params.order == "rand") then
          order = "RANDOM ()"
        else
          order = string.format("name %s", self.params.order)
        end

        local mangas
        local pag
        if (self.params.limit) then
          pag = Mangas:paginated(string.format("order by %s", order), nil, {
            per_page = self.params.limit,
          })
          mangas = pag:get_page(self.params.page)
        else
          mangas = Mangas:select(string.format("order by %s", order))
        end

        local out = {}
        for _,manga in pairs(mangas) do
          table.insert(out, {
            name = manga.name,
            author = manga.author,
            isbn = manga.isbn ~= "" and manga.isbn or "N/A",
            stock = manga.stock,
            price = price_fmt(manga.price),
            image = manga.image_path:sub(2),
            url = self:url_for('web.manga', { id = manga.id })
          })
        end

        return self:render_json({
          items = #out == 0 and cjson.empty_array or out
        })
      end,
    })

    return page
  end
}
