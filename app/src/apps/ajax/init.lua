local lapis = require("lapis")
local locale = require("locale")
local u = require("util")
local errcode = u.errcode

local app = lapis.Application()
app._base = app
app.include = function(self, a)
  self.__class.include(self, a, nil, self)
end

local function make_page(path)
  local _M = require(path)

  local page = lapis.Application()
  page.name = string.format("%s.", _M.name)
  page.path = _M.path

  page.action = function(frags)
    return u.catch(u.respond_to{
      POST = function(self)
        if (not self.params.__ajax_frag) then
          u.throw(u.errcode_fmt(errcode.field_not_found,
            "No fragment provided"))
        end
        local frag = self.params.__ajax_frag

        local frag_fun = frags[frag]
        if (not frag_fun) then
          u.throw(u.errcode_fmt(errcode.field_not_found,
            "Fragment not found '%s'", frag))
        end
        return frag_fun(self)
      end
    }, frags.on_error or function(self) return self:render("ajax.error") end)
  end

  return _M.setup(page)
end

app:before_filter(function(self)
  self.site_name = u.config.site_name
  self.page_title = self.site_name

  function self:getstr(name)
    return locale.getstr(name)
  end

  self.static_url = "/static/%s"
  self.files_url = "/files/%s/%s"

  function self:format_url(pattern, ...)
    self:build_url(string.format(pattern, ...))
  end

  function self:render(name)
    return { render = name, layout = false }
  end

  function self:redirect_to(name)
    return { redirect_to = self:url_for(name) }
  end
end)

app:include(make_page("apps.ajax.admin"))
app:include(make_page("apps.ajax.user"))

return app
