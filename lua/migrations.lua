local create_table, types, create_index, add_column
do
  local _obj_0 = require("lapis.db.schema")
  create_table, types, create_index, add_column = _obj_0.create_table, _obj_0.types, _obj_0.create_index, _obj_0.add_column
end
local db = require("lapis.db")
return {
  [1730498235] = function(self)
    create_table("items", {
      {
        "id",
        types.serial({
          primary_key = true
        })
      },
      {
        "name",
        types.text
      },
      {
        "price",
        types.real
      }
    })
    create_table("categories", {
      {
        "id",
        types.serial({
          primary_key = true
        })
      },
      {
        "name",
        types.text({
          unique = false
        })
      }
    })
    create_table("item_categories", {
      {
        "item_id",
        types.foreign_key({
          references = "items"
        })
      },
      {
        "category_id",
        types.foreign_key({
          references = "categories"
        })
      }
    })
    return create_index("item_categories", "item_id", "category_id", {
      unique = true
    })
  end,
  [1730629803] = function(self)
    return db.query("ALTER TABLE categories ADD CONSTRAINT unique_name UNIQUE (name)")
  end,
  [1731167132] = function(self)
    add_column("items", "created_at", types.time)
    return add_column("items", "updated_at", types.time)
  end,
  [1731169098] = function(self)
    add_column("categories", "created_at", types.time)
    return add_column("categories", "updated_at", types.time)
  end,
  [1731238364] = function(self)
    return db.query("ALTER TABLE items ADD COLUMN img_url TEXT NOT NULL DEFAULT ''")
  end
}
