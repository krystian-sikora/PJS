local respond_to, json_params
do
  local _obj_0 = require("lapis.application")
  respond_to, json_params = _obj_0.respond_to, _obj_0.json_params
end
local Items, Categories
do
  local _obj_0 = require("models")
  Items, Categories = _obj_0.Items, _obj_0.Categories
end
local lapis = require("lapis")
local db = require("lapis.db")
local google = require("cloud_storage.google")
local get_items_with_categories
get_items_with_categories = function(id)
  if id == nil then
    id = nil
  end
  local query = "\n      SELECT \n        items.id, \n        items.name,\n        items.price,\n        items.created_at,\n        items.updated_at,\n        items.img_url,\n        COALESCE(string_agg(categories.name, ', '), '') AS categories\n      FROM items\n      LEFT JOIN item_categories ON items.id = item_categories.item_id\n      LEFT JOIN categories ON item_categories.category_id = categories.id\n    "
  if id then
    query = query .. "WHERE items.id=" .. tostring(id)
  end
  query = query .. [[    GROUP BY items.id
    ORDER BY items.id
  ]]
  return db.query(query)
end
local Application
do
  local _class_0
  local _parent_0 = lapis.Application
  local _base_0 = {
    ["/hello"] = function(self)
      return {
        json = "Welcome to Lapis " .. tostring(require("lapis.version")) .. "!"
      }
    end,
    ["/test-storage"] = function(self)
      self.storage = google.CloudStorage:from_json_key_file("gcs_key.json")
      local bucket = "moonscript-images"
      local success, result = pcall(function()
        local files = self.storage:get_bucket(bucket)
        if files then
          return {
            success = true,
            files = files
          }
        else
          return {
            success = false,
            error = "No files found"
          }
        end
      end)
      if success then
        return {
          json = result
        }
      else
        return {
          json = {
            success = false,
            error = result
          }
        }
      end
    end,
    ["/items"] = respond_to({
      GET = function(self)
        return {
          json = get_items_with_categories()
        }
      end,
      POST = json_params(function(self)
        print("creating new item")
        local new_item = Items:create({
          name = self.params.name,
          price = self.params.price
        })
        return {
          status = 201,
          json = new_item
        }
      end)
    }),
    ["/items/:id"] = respond_to({
      GET = function(self)
        return {
          json = get_items_with_categories(self.params.id)
        }
      end,
      PUT = json_params(function(self)
        local item = Items:find(self.params.id)
        item:update({
          name = self.params.name,
          price = self.params.price,
          img_url = self.params.img_url
        })
        return {
          json = item
        }
      end),
      DELETE = function(self)
        local item = Items:find(self.params.id)
        if item then
          item:delete()
          return {
            status = 204
          }
        else
          return {
            status = 404,
            json = {
              error = "Item not found"
            }
          }
        end
      end
    }),
    ["/items/:id/image"] = respond_to({
      PUT = function(self)
        print("Processing image upload for product " .. tostring(self.params.id))
        self.storage = google.CloudStorage:from_json_key_file("gcs_key.json")
        self.bucket_name = "moonscript-images"
        local product = Items:find(self.params.id)
        if not (product) then
          return {
            status = 404,
            json = {
              success = false,
              error = "Product not found"
            }
          }
        end
        local image_data = self.req.params_post.image
        if not (image_data) then
          return {
            status = 400,
            json = {
              success = false,
              error = "No image provided"
            }
          }
        end
        local timestamp = os.time()
        local filename = "product_" .. tostring(product.id) .. "_" .. tostring(timestamp) .. ".jpg"
        print("Uploading file: " .. tostring(filename))
        local success, err = self.storage:put_file_string(self.bucket_name, filename, image_data.content, {
          mimetype = "image/jpeg",
          cache_control = "public, max-age=31536000"
        })
        if success then
          local image_url = self.storage:file_url(self.bucket_name, filename)
          print("Upload successful. URL: " .. tostring(image_url))
          product:update({
            img_url = image_url
          })
          return {
            json = {
              success = true,
              image_url = image_url
            }
          }
        else
          print("Upload failed: " .. tostring(err))
          return {
            status = 500,
            json = {
              success = false,
              error = "Failed to upload image: " .. tostring(err)
            }
          }
        end
      end
    }),
    ["/categories"] = respond_to({
      GET = function(self)
        return {
          json = Categories:select()
        }
      end,
      POST = json_params(function(self)
        local new_category = Categories:create({
          name = self.params.name
        })
        return {
          status = 201,
          json = new_category
        }
      end)
    }),
    ["/categories/:id"] = respond_to({
      GET = function(self)
        local category = Categories:find(self.params.id)
        return {
          json = category
        }
      end,
      PUT = json_params(function(self)
        local category = Categories:find(self.params.id)
        category:update({
          name = self.params.name
        })
        return {
          json = category
        }
      end),
      DELETE = function(self)
        local category = Categories:find(self.params.id)
        if category then
          category:delete()
          return {
            status = 204
          }
        else
          return {
            status = 404,
            json = {
              error = "Item not found"
            }
          }
        end
      end
    })
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ...)
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = "Application",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  Application = _class_0
  return _class_0
end
