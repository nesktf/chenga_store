local config = require("lapis.config")

config("development", {
  server = "nginx",
  port = "8080",
  code_cache = "off",
  num_workers = "1"
})
