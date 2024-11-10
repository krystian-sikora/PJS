import use_test_server from require "lapis.spec"
import request from require "lapis.spec.server"
db = require "lapis.db"
cjson = require "cjson"

clear_db = ->
  db.query "TRUNCATE item_categories RESTART IDENTITY"
  db.query "TRUNCATE items RESTART IDENTITY"
  db.query "TRUNCATE categories RESTART IDENTITY"

describe "my shop", ->
  use_test_server!
  clear_db()
  
  item = {
    name: "Apple"
    price: "0.99"
  }

  category = {
    name: "Food"
  }

  it "should reach /hello", ->
    status, body = request "/hello"

    assert.same 200, status
    assert.truthy body\match "Welcome to Lapis 1.16.0!"

  it "should reach /items", ->
    status = request "/items"
    
    assert.same 200, status

  it "should post /items", ->
    status, body = request "/items", {
      method: "POST"
      data: item
    }
    
    body = cjson.decode body
    item.id = body.id
    item.created_at = body.created_at
    item.updated_at = body.updated_at
    
    assert.same 1, body.id
    assert.same 201, status
    assert.same item, body

    status, body = request "/items"
    json_item = cjson.encode item
    
    assert.same 200, status
    assert.truthy body\match "[#{json_item}]"

  it "should update /items/:id", ->
    item.name = "Apple (Granny Smith)"
    item.img_url = "https://upload.wikimedia.org/wikipedia/commons/d/d7/Granny_smith_and_cross_section.jpg"

    status, body = request "/items/#{item.id}", {
      method: "PUT"
      data: item
    }
    body = cjson.decode body
    item.updated_at = body.updated_at

    assert.same 200, status
    assert.same item, body
    
    status, body = request "/items"
    json_item = cjson.encode item
    
    assert.same 200, status
    assert.truthy body\match "[#{json_item}]"

  it "should delete /items/:id", ->
    status, body = request "/items/#{item.id}", method: "DELETE"
    
    assert.same 204, status
    
    status, body = request "/items"
    
    assert.same 200, status
    assert.same "{}", body

  it "should reach /categories", ->
    status = request "/categories"
    
    assert.same 200, status

  it "should post /categories", ->
    status, body = request "/categories", {
      method: "POST"
      data: category
    }
    
    body = cjson.decode body
    category.id = body.id
    category.created_at = body.created_at
    category.updated_at = body.updated_at
    
    assert.same 1, body.id
    assert.same 201, status
    assert.same category, body

    status, body = request "/categories"
    json_category = cjson.encode category
    
    assert.same 200, status
    assert.truthy body\match "[#{json_category}]"

  it "should update /categories/:id", ->
    category.name = "Fruits"

    status, body = request "/categories/#{category.id}", {
      method: "PUT"
      data: category
    }
    body = cjson.decode body
    category.updated_at = body.updated_at
    
    assert.same 200, status
    assert.same category, body
    
    status, body = request "/categories"
    json_category = cjson.encode category
    
    assert.same 200, status
    assert.truthy body\match "[#{json_category}]"

  it "should delete /categories/:id", ->
    status, body = request "/categories/#{category.id}", method: "DELETE"
    
    assert.same 204, status
    
    status, body = request "/categories"
    
    assert.same 200, status
    assert.same "{}", body






 
