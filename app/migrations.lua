local db     = require("lapis.db")
local schema = require("lapis.db.schema")
local types = schema.types

return {
  [100] = function()
    schema.create_table("users", {
      { "id", types.serial{ unique = true, primary_key = true } },
      { "name", types.text },
      { "address", types.text },
      { "email", types.text{ unique = true } },
      { "username", types.text{ unique = true } },
      { "password", types.text },
      { "is_admin", types.boolean{ default = false } }
    })

    schema.create_table("mangas", {
      { "id", types.serial{ unique = true, primary_key = true} },
      { "name", types.text },
      { "author", types.text },
      { "isbn", types.text{ null = true } },
      { "stock", types.integer },
      { "price", types.integer },
      { "image_path", types.text{ null = true } },
    })

    schema.create_table("user_carts", {
      { "id", types.serial{ unique = true, primary_key = true } },
      { "subtotal", types.integer },
      { "discount", types.integer },
      { "total", types.integer },

      { "user_id", types.foreign_key },

      "FOREIGN KEY (user_id) REFERENCES users",
    })

    schema.create_table("cart_items", {
      { "id", types.serial{ unique = true, primary_key = true } },
      { "quantity", types.integer },

      { "user_cart_id", types.foreign_key },
      { "manga_id", types.foreign_key },

      "FOREIGN KEY (user_cart_id) REFERENCES user_carts",
      "FOREIGN KEY (manga_id) REFERENCES mangas",
    })

    schema.create_table("tags", {
      { "id", types.serial{ unique = true, primary_key = true } },
      { "name", types.text{ unique = true } },
    })

    schema.create_table("manga_tags", {
      { "id", types.serial{ unique = true, primary_key = true }, },

      { "manga_id", types.foreign_key },
      { "tag_id", types.foreign_key },

      "FOREIGN KEY (manga_id) REFERENCES mangas",
      "FOREIGN KEY (tag_id) REFERENCES tags",
    })

    schema.create_table("sales", {
      { "id", types.serial{ unique = true, primary_key = true } },
      { "sale_time", types.integer },
      { "quantity", types.integer },
      { "total", types.integer },

      { "user_id", types.foreign_key },
      { "manga_id", types.foreign_key },
      
      "FOREIGN KEY (user_id) REFERENCES users",
      "FOREIGN KEY (manga_id) REFERENCES mangas",
    })

    schema.create_table("vouchers",  {
      { "id", types.serial{ unique = true, primary_key = true } },
      { "code", types.text },
      { "discount", types.integer },
    })
  end,
  
  [101] = function()
    schema.create_table("user_favs", {
      { "id", types.serial{ unique = true, primary_key = true } },

      { "user_id", types.foreign_key },
      { "manga_id", types.foreign_key },

      "FOREIGN KEY (user_id) REFERENCES users",
      "FOREIGN KEY (manga_id) REFERENCES mangas",
    })
    schema.create_table("sale_cart", {
      { "id", types.serial{ unique = true, primary_key = true } },
      { "sale_time", types.integer },
      { "subtotal", types.integer },
      { "discount", types.integer { default = 0} },
      { "total", types.integer },

      { "user_id", types.foreign_key },

      "FOREIGN KEY (user_id) REFERENCES users",
    })
    schema.drop_table("sales")
    schema.drop_column("user_carts", "total")
    schema.drop_column("user_carts", "discount")

    schema.create_table("sales", {
      { "id", types.serial{ unique = true, primary_key = true } },
      { "quantity", types.integer },

      { "sale_cart_id", types.foreign_key },
      { "manga_id", types.foreign_key },
      
      "FOREIGN KEY (sale_cart_id) REFERENCES sale_cart",
      "FOREIGN KEY (manga_id) REFERENCES mangas",
    })
  end
}
