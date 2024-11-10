import create_table, types, create_index, add_column from require "lapis.db.schema"
db = require "lapis.db"

{
  [1730498235]: =>
    create_table "items", {
      { "id", types.serial primary_key: true }
      { "name", types.text }
      { "price", types.real }
    }

    create_table "categories", {
      { "id", types.serial primary_key: true }
      { "name", types.text unique: false }
    }

    create_table "item_categories", {
      { "item_id", types.foreign_key references: "items" }
      { "category_id", types.foreign_key references: "categories" }
    }

    create_index "item_categories", "item_id", "category_id", unique: true

  [1730629803]: =>
    db.query "ALTER TABLE categories ADD CONSTRAINT unique_name UNIQUE (name)"

  [1731167132]: =>
    add_column "items", "created_at", types.time
    add_column "items", "updated_at", types.time

  [1731169098]: =>
    add_column "categories", "created_at", types.time
    add_column "categories", "updated_at", types.time

  [1731238364]: =>
    db.query "ALTER TABLE items ADD COLUMN img_url TEXT NOT NULL DEFAULT ''"
}
