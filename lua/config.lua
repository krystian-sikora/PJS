local config
config = require("lapis.config").config
local load_env
load_env = function(file_path)
  if file_path == nil then
    file_path = ".env"
  end
  local vars = { }
  for line in io.lines(file_path) do
    local key, value = line:match("^%s*([^=]+)%s*=%s*(.+)%s*$")
    if key and value then
      vars[key] = value
    end
  end
  return vars
end
local env = load_env()
config("development", function()
  server("nginx")
  code_cache("off")
  num_workers("1")
  port(5050)
  return postgres(function()
    host("127.0.0.1")
    user(env["POSTGRES_USER"])
    password(env["POSTGRES_PASSWORD"])
    database("db_shop")
    return port(5432)
  end)
end)
return config("test", function()
  server("nginx")
  code_cache("off")
  num_workers("1")
  port(8081)
  return postgres(function()
    user("test")
    password("test")
    database("db_shop_test")
    return port(8082)
  end)
end)
