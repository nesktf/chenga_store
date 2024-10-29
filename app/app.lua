local lapis = require("lapis")

local app = lapis.Application()
function app:include(a)
  self.__class.include(self, a, nil, self)
end

app:enable("etlua")
app.layout = require("views.layout")

do
  function app.handle_404()
    return {
      status = 404,
      json = { "Not found!" }
    }
  end
end

app:include("apps.api")
app:include("apps.web")

return app
