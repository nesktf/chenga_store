local u = require("util")
local cjson = require("cjson")
local Mangas = require("models.mangas")

local function setup(page)
  page:match("query", "", page.make_action {
    parse_json = true,
    on_error = function(self)
      return {
        json = {
          ok = false,
          error = self.errors[1],
        }
      }
    end,
    GET = function(_)
      local mangas = Mangas:get_all()
      local out = {}
      for _, manga in ipairs(mangas) do
        table.insert(out, {
          id = manga.id,
          name = manga.name,
          price = manga.price,
          discount = manga.discount,
        })
      end

      return {
        json = {
          ok = true,
          mangas = #out == 0 and cjson.empty_array or out,
        }
      }
    end,
    PUT = function(self)
      local id = u.assert(tonumber(self.params.id), "No manga id")
      local manga = u.assert(Mangas:get(id))
      local value = u.assert(tonumber(self.params.value), "No discount value")
      u.assert(value >= 0 and value <= 100, "Discount value out of range")
      manga:update{
        discount = value,
      }

      return {
        json = {
          ok = true,
          manga = manga,
          value = value,
        }
      }
    end,
  })
  return page
end

return {
  path = "/api/discounts",
  name = "api.discounts",
  setup = setup,
}
