local lapis_util = require("lapis.application")
local validate_types = require("lapis.validate.types")

local _M = {}

_M.assert = lapis_util.assert_error
_M.capture = lapis_util.capture_errors
_M.capture_json = lapis_util.capture_errors_json


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

function _M.throw(code, msg, ...)
  return nil, {
    code = code,
    msg = string.format(msg, ...)
  }
end

function _M.yield(code, msg, ...)
  lapis_util.yield_error({
    code = code,
    msg = string.format(msg, ...)}
  )
end

_M.code = (function()
  local err = {}

  -- Auth
  function err.malformed_authorization(msg, ...)
    return _M.throw(100, msg, ...)
  end

  function err.invalid_authorization(msg, ...)
    return _M.throw(101, msg, ...)
  end

  function err.unauthorized_access(msg, ...)
    return _M.throw(102, msg, ...)
  end

  -- Data Validation
  function err.field_not_found(msg, ...)
    return _M.throw(200, msg, ...)
  end
  function err.field_invalid(msg, ...)
    return _M.throw(201, msg, ...)
  end
  function err.field_not_unique(msg, ...)
    return _M.throw(202, msg, ...)
  end
  function err.token_expired(msg, ...)
    return _M.throw(203, msg, ...)
  end
  function err.password_not_match(msg, ...)
    return _M.throw(204, msg, ...)
  end

  -- Database I/O
  function err.db_unresponsive(msg, ...)
    return _M.throw(300, msg, ...)
  end
  function err.db_create(msg, ...)
    return _M.throw(301, msg, ...)
  end
  function err.db_update(msg, ...)
    return _M.throw(302, msg, ...)
  end
  function err.db_delete(msg, ...)
    return _M.throw(303, msg, ...)
  end
  function err.db_select(msg, ...)
    return _M.throw(304, msg, ...)
  end

  return err
end)()

function _M.make_validator(record)
  local validate = validate_types.shape(record)
  return function(_, params)
    local valid, err = validate(params)
    if (not valid) then
      return _M.code.field_invalid("Validation failed: %s", err)
    end

    return params
  end
end

return _M
