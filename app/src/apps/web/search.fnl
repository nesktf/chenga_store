(local Mangas (require :models.mangas))

(local manga-query
       "where lower(name) like lower('%' || ? || '%') order by name asc limit ? offset ?")

[{:name "search"
  :path "/search"
  :actions {:GET (fn [self]
                   (self:set_title "Search")
                   (let [mangas (Mangas:select manga-query self.params.q 10 0)
                         manga-len (length mangas)]
                     (set self.mangas (if (not= manga-len 0) mangas nil))
                     (self:render "web.search")))}}]
