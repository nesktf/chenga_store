(local lapis-page (require :page))

(let [page (lapis-page "test" "/test")]
  (page:req "" "/" {:GET (fn [self]
                           {:render "code_404"})})
  page)
