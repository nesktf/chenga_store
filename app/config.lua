local config = require("lapis.config")

-- Lua libraries
local lua_path = "./src/?.lua;./src/?/init.lua"
local lua_cpath = ""

-- Max file size
local body_size = "15m"

local postgres = {
  host = "127.0.0.1",
  user = "postgres",
  password = "password",
  database = "ecommerce",
}

local site_name = "ecommerce"

config("development", {
  site_name   = "[DEV] "..site_name,
  port        = 8080,

  server      = "nginx",
  code_cache  = "off",
  num_workers = "1",

  body_size   = body_size,
  lua_path    = lua_path,
  lua_cpath   = lua_cpath,

  postgres    = postgres,
})

config("production", {
  site_name   = site_name,
  port        = 8080,

  server      = "nginx",
  code_cache  = "on",
  num_workers = "4",

  body_size   = body_size,
  lua_path    = lua_path,
  lua_cpath   = lua_cpath,

  postgres    = postgres,
})
