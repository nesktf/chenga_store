<div align="center">
    <picture>
        <source
            media="(prefers-color-scheme: dark)"
            srcset="app/static/logo_dark.png" />
        <source
            media="(prefers-color-scheme: light), (prefers-color-scheme: no-preference)"
            srcset="app/static/logo_light.png" />
        <img alt="chenga" src="app/static/logo_light.png" />
    </picture>
</div>

# Chenga
Simple manga e-commerce I made for a college project. Writen in Lua, using 
[lapis](https://github.com/leafo/lapis),
[htmx](https://github.com/bigskysoftware/htmx),
and [picocss](https://github.com/picocss/pico).

## Running
Only tested on Debian 12 Bookworm, should work fine in other distros.
May or may not run on Windows.

Install PostgreSQL, Luarocks and Lua5.1/LuaJIT using your system package manager, then download
the luarocks dependencies.
```sh
sudo apt install postgresql postgresql-contrib luarocks liblua5.1-dev libluajit-5.1-dev
luarocks install lapis lua-cjson bcrpyt tableshape bit lpeg --local --lua-version=5.1
```

You need to add the `data/secret.lua` file, it should only return a string to be
used as a secret token.
```lua
-- data/secret.lua
return "myfunnysecrethehehaha"
```

By default, PostgreSQL should be running in port 5432, have an `ecommerce` database and
password `password` for user `postgres`. You can modify this in `app/config.lua`.
The queries in `sql_init.sql` can be used to create the database.

Go inside the `app/` folder and run the following command (don't forget to load your
luarocks environment):
```sh
lapis server development
```

The website runs on port 8080 by default

## Images
### Dashboard
![chenga_admin](img/chenga_admin.png) 

