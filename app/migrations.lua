local schema = require("lapis.db.schema")
local types = schema.types

return {
  [100] = function()
    schema.create_table("users", {
      { "id", types.serial{ unique = true, primary_key = true } },
      { "name", types.text },
      { "address", types.text },
      { "email", types.text{ unique = true } },
      { "user", types.text{ unique = true } },
      { "pass", types.text },
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
      { "name", types.text{ unique = true } },
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
      { "date_appended", types.time },
      { "stock", types.integer },

      { "provider_id", types.foreign_key },
    })

    schema.create_table("product_categories", {
      { "id", types.serial{ unique = true, primary_key = true } },

      { "category_id", types.foreign_key },
      { "product_id", types.foreign_key },
    })

    schema.create_table("sales", {
      { "id", types.serial{ unique = true, primary_key = true } },
      { "date", types.time },
      { "total", types.integer },

      { "user_id", types.foreign_key },
      { "payment_type_id", types.foreign_key },
    })

    schema.create_table("product_sales", {
      { "id", types.serial{ unique = true, primary_key = true } },

      { "sale_id", types.foreign_key },
      { "product_id", types.foreign_key },
    })

    schema.create_table("discounts", {
      { "id", types.serial{ unique = true, primary_key = true } },
      { "date_init", types.time },
      { "date_end", types.time },
      { "value", types.integer },

      { "category_id", types.foreign_key },
    })
  end
}
