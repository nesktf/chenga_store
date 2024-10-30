local es = require("locale.es")

local _M = {}

function _M.getstr(str)
  return es[str]
end

return _M
