[{:name "index"
  :path "/"
  :actions {:GET (fn [self]
                   (self:set_title "Home")
                   (self:render :web.index))}}]
