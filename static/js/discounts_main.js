
function getTable() {
  return [
    document.getElementById("discount_table"),
    document.getElementById("discount_table_item").innerHTML
  ];
}

async function fetchDiscounts(onFetch) {
  fetch(discountAPI, {
    method: 'GET',
    headers: { 'Content-Type': 'application/json' },
  })
  .then(async body => body.json())
  .then((json) => {
    if (!json.ok) {
      console.log(json.error);
    }
    onFetch(json.mangas);
  })
}

const formatPercentage = (perc) => {
  return Intl.NumberFormat('es-AR', {
    style: "percent"
  }).format(perc/100);
}

var old_value = null;
function updateItem(butt, id, event) {
  const modal_content = document.getElementById('modal_content');
  const modal_header = document.getElementById('modal_header');
  const modal_footer = document.getElementById('modal_footer');

  const showInput = (elem, flag) => {
    elem.children[0].hidden = flag;
    elem.children[1].hidden = !flag;
  }
  const template = document.getElementById('modal_template');
  const onErr = (elem, err) => {
    console.log(err);
    showInput(elem, false);
    elem.children[1].value = old_value;
    butt.innerHTML = "Modify";
    modal_header.innerHTML = "<h4>Error</h4>";
    modal_content.innerHTML = `<p>${err}</p>`;
    modal_footer.innerHTML = Mustache.render(template.innerHTML, {});
    toggle_modal(event);
  };

  const onSucc = (elem, manga) => {
    showInput(elem, false);
    elem.children[0].innerHTML = formatPercentage(manga.discount);
    elem.children[1].value = manga.discount;
    butt.innerHTML = "Modify";
    modal_header.innerHTML = "<h4>Success!</h4>";
    modal_content.innerHTML = `<p>Discount updated</p>`;
    modal_footer.innerHTML = Mustache.render(template.innerHTML, {});
    toggle_modal(event);
  };

  const putItem = async (elem, value) => {
    fetch(discountAPI, {
      method: "PUT",
      body: JSON.stringify({
        id: parseInt(id),
        value: parseInt(value),
      }),
      headers: { 'Content-Type': 'application/json' },
    })
    .then(async (body) => {
      if (!body.ok) {
        onErr(elem, "Request failed");
        return;
      }
      return await body.json();
    })
    .then((json) => {
      if (json.error !== undefined) {
        onErr(elem, json.error);
        return;
      }
      onSucc(elem, json.manga);
    })
    .catch(err => onErr(elem, err));
  }

  const elem = document.getElementById(`disc_item_${id}`);
  if (butt.innerHTML == "Modify") {
    butt.innerHTML = "Submit";
    old_value = elem.children[1].value;
    showInput(elem, true);
  } else {
    const value = elem.children[1].value;
    putItem(elem, value);
  }
}

function discountMain() {
  const [disc_table, disc_templ] = getTable();

  const formatPrice = (price) => {
    return Intl.NumberFormat('es-AR', {
      style: "currency",
      currency: "ARS",
    }).format(price/100);
  }

  fetchDiscounts((discounts) => {
    discounts.forEach((item) => {
      const html = Mustache.render(disc_templ, {
        id: item.id,
        name: item.name,
        price: formatPrice(item.price),
        discount_fmt: formatPercentage(item.discount),
        discount: item.discount,
      });
      const element = document.createElement("tr");
      element.innerHTML = html;
      disc_table.appendChild(element);
    })
  })
}
