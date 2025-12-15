local json = require("cjson")
local ngx  = ngx

local lapis_util = require("lapis.application")
local validate_types = require("lapis.validate.types")

local _M = {}

_M.config = require("lapis.config").get()
_M.errcode = {
  malformed_auth = 100,
  invalid_auth = 101,
  unauthorized_access = 102,

  field_not_found = 200,
  field_invalid = 201,
  field_not_unique = 202,
  token_expired = 203,
  password_not_match = 204,

  db_unresponsive = 300,
  db_create = 301,
  db_update = 302,
  db_delete = 303,
  db_select = 304,

  generic = 401,
  not_allowed = ngx.HTTP_NOT_ALLOWED,
}

_M.assert = lapis_util.assert_error
_M.throw = lapis_util.yield_error
_M.catch = lapis_util.capture_errors
_M.catch_json = lapis_util.capture_errors_json
_M.respond_to = lapis_util.respond_to
_M.json_params = lapis_util.json_params

function _M.catch_parse_json(fun)
  return _M.catch_json(_M.json_params(fun))
end

function _M.err_fmt(msg, ...)
  return {
    what = string.format(msg, ...)
  }
end

function _M.err_json(status, tbl)
  return {
    status = status,
    json = tbl,
  }
end

function _M.errcode_fmt(status, msg, ...)
  return {
    status = status,
    what = string.format(msg, ...)
  }
end

function _M.make_action(args)
  local function action_err()
    _M.throw(_M.errcode_fmt(_M.errcode.not_allowed, "Not allowed"))
  end

  local _base_action = {
    GET = action_err,
    POST = action_err,
    PUT = action_err,
    DELETE = action_err,
  }
  _base_action.__index = _base_action

  local err_handler = args.on_error or function(self)
    return { json = self.errors[1] }
  end

  if (args.parse_json) then
    return _M.catch(_M.json_params(_M.respond_to(setmetatable(args, _base_action))), err_handler)
  else
    return _M.catch(_M.respond_to(setmetatable(args, _base_action)), err_handler)
  end
end

function _M.make_validator(record)
  local validate = validate_types.shape(record)
  return function(_, params)
    local valid, err = validate(params)
    if (not valid) then
      return _M.errcode_fmt(_M.errcode.field_invalid, "Validation failed: %s", err)
    end

    return params
  end
end

function _M.do_request(method, uri, body)
	local response = ngx.location.capture(uri, {
		method = method,
		body   = json.encode(body)
	})

  if (response.truncated) then
    return nil
  end

	if (response.status ~= ngx.HTTP_OK) then
		return nil, json.decode(response.body)
	end

	return json.decode(response.body)
end

function _M.req_get(uri, body)
  return _M.do_request(ngx.HTTP_GET, uri, body)
end

function _M.req_post(uri, body)
  return _M.do_request(ngx.HTTP_POST, uri, body)
end

function _M.req_put(uri, body)
  return _M.do_request(ngx.HTTP_PUT, uri, body)
end

function _M.req_delete(uri, body)
  return _M.do_request(ngx.HTTP_DELETE, uri, body)
end

local function print_table(tbl, indent)
  indent = indent or ""
  for k, v in pairs(tbl) do
    print(string.format("%s: ", tostring(k)))
    if (type(v) == "table") then
      print_table(v, string.format("%s ", indent))
    else
      print(string.format("%s\n", tostring(v)))
    end
  end
end

_M.print_table = print_table

function _M:write_error_json(status)
  for _, err in ipairs(self.errors) do
    if (type(err) == "table") then
      print_table(err)
    else
      print(err)
    end
  end
  print(#self.errors)

  return self:write(_M.err_json(status, self.errors))
end

return _M
