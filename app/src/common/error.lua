local lapis_util = require("lapis.application")

local _M = {}

_M.assert = lapis_util.assert_error
_M.capture = lapis_util.capture_errors
_M.capture_json = lapis_util.capture_errors_json

_M.errcode = (function()
  local err = {}

  -- email:api_key format in Authorization HTTP header is invalid
  function err.malformed_authorization()
    return { code=100 }
  end

  -- email:api_key in Authorization HTTP header does not match any user
  -- login credentials do not match any user
  function err.invalid_authorization()
    return { code=101 }
  end

  -- Attempting to access endpoint that requires higher priviliges
  function err.unauthorized_access()
    return { code=102 }
  end

  -- Data Validation
  function err.field_not_found(field)
    return { code=200, field=field }
  end
  function err.field_invalid(field)
    return { code=201, field=field }
  end
  function err.field_not_unique(field)
    return { code=202, field=field }
  end
  function err.token_expired(field)
    return { code=203, field=field }
  end
  function err.password_not_match()
    return { code=204 }
  end

  -- Database I/O
  function err.database_unresponsive()
    return { code=300 }
  end
  function err.database_create()
    return { code=301 }
  end
  function err.database_modify()
    return { code=302 }
  end
  function err.database_delete()
    return { code=303 }
  end
  function err.database_select()
    return { code=304 }
  end

  return err
end)()

local function print_table(table)
  for k, v in ipairs(table) do
    if (type(v) == "table") then
      print_table(v)
    end
    print(k, ": ", v)
  end
end

function _M:on_error()
  for _, err in ipairs(self.errors) do
    if (type(err) == "table") then
      print_table(err)
    else
      print(err)
    end
  end
  print(#self.errors)

  return self:write {
    status = 401,
    json   = self.errors
  }
end

function _M.throw(msg, ...)
  return false, {
    msg = msg,
    info = { ... }
  }
end

function _M.yield(msg, ...)
  lapis_util.yield_error({
    msg = msg,
    info = {...}
  })
end

return _M
