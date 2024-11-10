local use_test_server
use_test_server = require("lapis.spec").use_test_server
local request
request = require("lapis.spec.server").request
local db = require("lapis.db")
local cjson = require("cjson")
local clear_db
clear_db = function()
  db.query("TRUNCATE item_categories RESTART IDENTITY")
  db.query("TRUNCATE items RESTART IDENTITY")
  return db.query("TRUNCATE categories RESTART IDENTITY")
end
return describe("my shop", function()
  use_test_server()
  clear_db()
  local item = {
    name = "Apple",
    price = "0.99"
  }
  local category = {
    name = "Food"
  }
  it("should reach /hello", function()
    local status, body = request("/hello")
    assert.same(200, status)
    return assert.truthy(body:match("Welcome to Lapis 1.16.0!"))
  end)
  it("should reach /items", function()
    local status = request("/items")
    return assert.same(200, status)
  end)
  it("should post /items", function()
    local status, body = request("/items", {
      method = "POST",
      data = item
    })
    body = cjson.decode(body)
    item.id = body.id
    item.created_at = body.created_at
    item.updated_at = body.updated_at
    assert.same(1, body.id)
    assert.same(201, status)
    assert.same(item, body)
    status, body = request("/items")
    local json_item = cjson.encode(item)
    assert.same(200, status)
    return assert.truthy(body:match("[" .. tostring(json_item) .. "]"))
  end)
  it("should update /items/:id", function()
    item.name = "Apple (Granny Smith)"
    item.img_url = "https://upload.wikimedia.org/wikipedia/commons/d/d7/Granny_smith_and_cross_section.jpg"
    local status, body = request("/items/" .. tostring(item.id), {
      method = "PUT",
      data = item
    })
    body = cjson.decode(body)
    item.updated_at = body.updated_at
    assert.same(200, status)
    assert.same(item, body)
    status, body = request("/items")
    local json_item = cjson.encode(item)
    assert.same(200, status)
    return assert.truthy(body:match("[" .. tostring(json_item) .. "]"))
  end)
  it("should delete /items/:id", function()
    local status, body = request("/items/" .. tostring(item.id), {
      method = "DELETE"
    })
    assert.same(204, status)
    status, body = request("/items")
    assert.same(200, status)
    return assert.same("{}", body)
  end)
  it("should reach /categories", function()
    local status = request("/categories")
    return assert.same(200, status)
  end)
  it("should post /categories", function()
    local status, body = request("/categories", {
      method = "POST",
      data = category
    })
    body = cjson.decode(body)
    category.id = body.id
    category.created_at = body.created_at
    category.updated_at = body.updated_at
    assert.same(1, body.id)
    assert.same(201, status)
    assert.same(category, body)
    status, body = request("/categories")
    local json_category = cjson.encode(category)
    assert.same(200, status)
    return assert.truthy(body:match("[" .. tostring(json_category) .. "]"))
  end)
  it("should update /categories/:id", function()
    category.name = "Fruits"
    local status, body = request("/categories/" .. tostring(category.id), {
      method = "PUT",
      data = category
    })
    body = cjson.decode(body)
    category.updated_at = body.updated_at
    assert.same(200, status)
    assert.same(category, body)
    status, body = request("/categories")
    local json_category = cjson.encode(category)
    assert.same(200, status)
    return assert.truthy(body:match("[" .. tostring(json_category) .. "]"))
  end)
  return it("should delete /categories/:id", function()
    local status, body = request("/categories/" .. tostring(category.id), {
      method = "DELETE"
    })
    assert.same(204, status)
    status, body = request("/categories")
    assert.same(200, status)
    return assert.same("{}", body)
  end)
end)
