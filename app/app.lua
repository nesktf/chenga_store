local lapis = require("common").lapis
local ngx = ngx

local app = lapis.make_app{}

app:enable("etlua")
app.layout = require("views.layout")

do
	function app.handle_404()
		local api = ngx.var.uri:match("^(/api).+$")

		if (not api) then
			return { render="code_404" }
    end

    return {
      status = 404,
      json   = { "Resource not found!" }
    }
	end
end

app:include("apps.api")
app:include("apps.web")

return app
