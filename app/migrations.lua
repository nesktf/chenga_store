local schema = require("lapis.db.schema")
local types = schema.types

local function init_tables()
  schema.create_table("admins", {
    { "id", types.serial{ unique = true, primary_key = true} },
    { "username", types.text{ unique = true } },
    { "password", types.text },
  })

  schema.create_table("users", {
    { "id", types.serial{ unique = true, primary_key = true } },
    { "name", types.text },
    { "address", types.text },
    { "email", types.text{ unique = true } },
    { "username", types.text{ unique = true } },
    { "password", types.text },
  })

  schema.create_table("providers", {
    { "id", types.serial{ unique = true, primary_key = true } },
    { "name", types.text },
    { "address", types.text },
    { "email", types.text{ unique = true } },
    { "cuit", types.text },
  })

  schema.create_table("categories", {
    { "id", types.serial{ unique = true, primary_key = true } },
    { "name", types.text{ unique = true } },
  })

  schema.create_table("payment_types", {
    { "id", types.serial{ unique = true, primary_key = true } },
    { "name", types.text },
  })

  schema.create_table("vouchers",  {
    { "id", types.serial{ unique = true, primary_key = true } },
    { "value", types.integer },
    { "code", types.text },
  })

  schema.create_table("products", {
    { "id", types.serial{ unique = true, primary_key = true } },
    { "name", types.text },
    { "price", types.integer },
    { "date_appended", types.date },
    { "stock", types.integer },

    { "provider_id", types.foreign_key },

    "FOREIGN KEY (provider_id) REFERENCES providers",
  })

  schema.create_table("product_categories", {
    { "id", types.serial{ unique = true, primary_key = true } },

    { "category_id", types.foreign_key{ null = true } },
    { "product_id", types.foreign_key },

    "FOREIGN KEY (category_id) REFERENCES categories",
    "FOREIGN KEY (product_id) REFERENCES products",
  })

  schema.create_table("sales", {
    { "id", types.serial{ unique = true, primary_key = true } },
    { "date", types.date },
    { "total", types.integer },

    { "user_id", types.foreign_key { null = true } },
    { "payment_type_id", types.foreign_key{ null = true } },

    "FOREIGN KEY (user_id) REFERENCES users",
    "FOREIGN KEY (payment_type_id) REFERENCES payment_types",
  })

  schema.create_table("product_sales", {
    { "id", types.serial{ unique = true, primary_key = true } },

    { "sale_id", types.foreign_key },
    { "product_id", types.foreign_key },

    "FOREIGN KEY (sale_id) REFERENCES sales",
    "FOREIGN KEY (product_id) REFERENCES products",
  })

  schema.create_table("discounts", {
    { "id", types.serial{ unique = true, primary_key = true } },
    { "date_init", types.date },
    { "time_init", types.time},
    { "date_end", types.date },
    { "time_end", types.time },
    { "value", types.integer },

    { "category_id", types.foreign_key },

    "FOREIGN KEY (category_id) REFERENCES categories",
  })
end

return {
  [100] = init_tables,
}
