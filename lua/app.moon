import respond_to, json_params from require "lapis.application"
import Items, Categories from require "models"
lapis = require "lapis"
db = require "lapis.db"
google = require "cloud_storage.google"

get_items_with_categories = (id = nil) ->
  query = "
      SELECT 
        items.id, 
        items.name,
        items.price,
        items.created_at,
        items.updated_at,
        items.img_url,
        COALESCE(string_agg(categories.name, ', '), '') AS categories
      FROM items
      LEFT JOIN item_categories ON items.id = item_categories.item_id
      LEFT JOIN categories ON item_categories.category_id = categories.id
    "

  if id 
    query = query .. "WHERE items.id=#{id}"

  query =  query .. [[
    GROUP BY items.id
    ORDER BY items.id
  ]]

  return db.query query

class Application extends lapis.Application
  "/hello": =>
    { json: "Welcome to Lapis #{require "lapis.version"}!" }
  "/test-storage": => 
    @storage = google.CloudStorage\from_json_key_file "gcs_key.json"
    bucket = "moonscript-images"
    
    success, result = pcall ->
      files = @storage\get_bucket bucket
      if files
        { success: true, files: files }
      else
        { success: false, error: "No files found" }

    if success
      return { json: result }
    else
      return { json: { success: false, error: result } }
    
  "/items": respond_to {
    GET: => {
      json: get_items_with_categories()
    }
    POST: json_params =>
      print "creating new item"
      new_item = Items\create {
        name: @params.name
        price: @params.price
      }
      return { status: 201, json: new_item }
  }
  "/items/:id": respond_to {
    GET: =>
      return { json: get_items_with_categories @params.id }
    PUT: json_params =>
      item = Items\find @params.id
      item\update {
        name: @params.name
        price: @params.price
        img_url: @params.img_url
      }
      return { json: item }
    DELETE: =>
      item = Items\find @params.id
      if item
        item\delete!
        return { status: 204 }
      else
        return { status: 404, json: { error: "Item not found" } }
  }
  "/items/:id/image": respond_to {
    PUT: =>
      print "Processing image upload for product #{@params.id}"
      @storage = google.CloudStorage\from_json_key_file "gcs_key.json"
      @bucket_name = "moonscript-images"

      product = Items\find @params.id
      return { status: 404, json: { success: false, error: "Product not found" }} unless product

      image_data = @req.params_post.image
      return { status:400, json: { success: false, error: "No image provided" }} unless image_data

      timestamp = os.time!
      filename = "product_#{product.id}_#{timestamp}.jpg"

      print "Uploading file: #{filename}"

      success, err = @storage\put_file_string @bucket_name, filename, image_data.content, {
        mimetype: "image/jpeg"
        cache_control: "public, max-age=31536000"
      }

      if success
        image_url = @storage\file_url @bucket_name, filename
        print "Upload successful. URL: #{image_url}"

        product\update {
          img_url: image_url
        }

        return json: { success: true, image_url: image_url }
      else
        print "Upload failed: #{err}"
        return { status: 500, json: { success: false, error: "Failed to upload image: #{err}" }}
    }
  "/categories": respond_to {
    GET: => return { json: Categories\select! }
    POST: json_params =>
      new_category = Categories\create {
        name: @params.name
      }
      return { status: 201, json: new_category}
  }
  "/categories/:id": respond_to {
    GET: =>
      category = Categories\find @params.id
      return { json: category }
    PUT: json_params =>
      category = Categories\find @params.id
      category\update {
        name: @params.name
      }
      return { json: category }
    DELETE: =>
      category = Categories\find @params.id
      if category
        category\delete!
        return { status: 204 }
      else
        return { status: 404, json: { error: "Item not found" } }
  }
