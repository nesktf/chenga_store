#!/usr/bin/env bash

if [[ -n "${1}" ]]; then
  cat "${1}" | docker exec -i postgres_chenga psql -U chenga -d chenga_ecommerce
else
  docker exec -it postgres_chenga psql -U chenga -d chenga_ecommerce
fi

