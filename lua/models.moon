import Model from require "lapis.db.model"
import autoload from require "lapis.util"

class Items extends Model
    @primary_key: "id"
    @timestamp: true

    @relations: {
        categories: =>
            @many_to_many "Categories", {
                join_table: "items_categories"
                key: "item_id"
                foreign_key: "category_id"
            }
    }

class Categories extends Model
    @primary_key: "id"
    @timestamp: true

    @relations: {
        items: =>
            @many_to_many "Items", {
                join_table: "items_categories"
                key: "category_id"
                foreign_key: "item_id"
            }
    }

autoload "models"

return {
    Items: Items
    Categories: Categories
}