local json = require("cjson")
local ngx  = ngx

local function req(method, uri, body)
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

local _M = {}

function _M.get(...)
  return req(ngx.HTTP_GET, ...)
end

function _M.post(...)
  return req(ngx.HTTP_POST, ...)
end

function _M.put(...)
  return req(ngx.HTTP_PUT, ...)
end

function _M.delete(...)
  return req(ngx.HTTP_DELETE, ...)
end

return _M
