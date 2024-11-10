import config from require "lapis.config"

load_env = (file_path = ".env") ->
  vars = {}
  for line in io.lines file_path
    key, value = line\match "^%s*([^=]+)%s*=%s*(.+)%s*$"
    if key and value
      vars[key] = value
  return vars
env = load_env()

config "development", ->
  server "nginx"
  code_cache "off"
  num_workers "1"
  port 5050
  postgres ->
    host "127.0.0.1"
    user env["POSTGRES_USER"]
    password env["POSTGRES_PASSWORD"]
    database "db_shop"
    port 5432

config "test", ->
  server "nginx"
  code_cache "off"
  num_workers "1"
  port 8081
  postgres ->
    user "test"
    password "test"
    database "db_shop_test"
    port 8082
