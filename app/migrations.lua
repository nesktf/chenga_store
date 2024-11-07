local schema = require("lapis.db.schema")
local types = schema.types

local function init_tables()
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

  schema.create_table("cart_items", {
    { "id", types.serial{ unique = true, primary_key = true } },
    { "price", types.integer },
    { "quantity", types.integer },
    { "subtotal", types.integer },
    { "discount", types.integer },
    { "total", types.integer },

    { "user_id", types.foreign_key },
    { "manga_id", types.foreign_key },

    "FOREIGN KEY (user_id) REFERENCES users",
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
    { "sale_time", types.time },
    { "total", types.integer },

    { "user_id", types.foreign_key{ null = true } },
    
    "FOREIGN KEY (user_id) REFERENCES users",
  })

  schema.create_table("vouchers",  {
    { "id", types.serial{ unique = true, primary_key = true } },
    { "code", types.text },
    { "discount", types.integer },
  })
end

return {
  [100] = init_tables,
}
