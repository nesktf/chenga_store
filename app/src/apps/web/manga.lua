local lapis = require("common").lapis
local error = require("common").error
local errcode = error.code
local action = lapis.make_action()
local Mangas = require("models.mangas")

function action:GET()
  if (not self.params.id) then
    error.yield(errcode.field_not_found, "ID not provided")
  end

  self.manga = Mangas:get(self.params.id)
  return { render = "web.manga" }
end

return action
