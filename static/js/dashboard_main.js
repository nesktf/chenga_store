function downloadURI(uri, name)  {
  var link = document.createElement("a");
  link.download = name;
  link.href = uri;
  link.click();
}

function formatPrice(price) {
  return Intl.NumberFormat('es-AR', {
    style: "currency",
    currency: "ARS",
  }).format(price);
}

async function doQuery(url, onSucc, args) {
  const onErr = (err) => {
    // if (onErr !== undefined) {
    //   onErr(err);
    // } else {
      console.log(err);
    // }
  };
  const make_args = () => {
    if (args !== undefined) {
      return {
        method: "POST",
        body: JSON.stringify(args),
        headers: { 'Content-Type': 'application/json' },
      }
    } else {
      return {
        method: "GET",
        body: JSON.stringify(args),
        headers: { 'Content-Type': 'application/json' },
      };
    }
  };
  return fetch(url, make_args())
  .then(async (body) => {
    if (!body.ok) {
      onErr("Request failed");
      return;
    }
    return await body.json();
  })
  .then((json) => {
    if (json.error !== undefined) {
      onErr(json.error);
      return;
    }
    onSucc(json);
  })
  .catch(err => onErr(err));
}

async function downloadMangas(ev) {
  const onFetch = (json) => {
    console.log(json.path);
    downloadURI(json.path, "chenga_report_manga.csv");
  };
  doQuery(mangas_api, onFetch, {})
}

async function downloadUsers(ev) {
  const onFetch = (json) => {
    console.log(json.path);
    downloadURI(json.path, "chenga_report_users.csv");
  };
  doQuery(users_api, onFetch, {})
}

async function populateMangas() {
  const onFetch = (json) => {
    console.log(json);
    const tbl = document.getElementById("manga_table");
    const templ = document.getElementById("manga_item").innerHTML;
    json.mangas.forEach((manga) => {
      const element = document.createElement("tr");
      element.innerHTML = Mustache.render(templ, {
        name: manga.name,
        sales: manga.sales,
        total: formatPrice(manga.total),
      });
      tbl.appendChild(element);
    });

    const total = json.mangas.reduce((prev, curr) => {
      return prev + curr.total;
    }, 0);
    document.getElementById("total_manga").innerHTML =`Total: ${formatPrice(total)}`;

    new Chart(document.getElementById("manga_graph0"), {
      type: 'bar',
      data: {
        labels: json.mangas.map((manga) => manga.name),
        datasets: [
          {
            label: "Total sales",
            data: json.mangas.map((item) => item.sales),
          }
        ],
      },
      options: {
        plugins: {
          title: {
            display: true,
            text: "Manga sales",
          },
        },
        responsive: true,
        scales: {
          x: {
            stacked: true,
          },
          y: {
            stacked: true
          }
        }
      }
    });
    new Chart(document.getElementById("manga_graph1"), {
      type: 'bar',
      data: {
        labels: json.mangas.map((manga) => manga.name),
        datasets: [
          {
            label: "Total income",
            data: json.mangas.map((item) => item.total),
          }
        ],
      },
      options: {
        plugins: {
          title: {
            display: true,
            text: "Manga income",
          },
        },
        responsive: true,
        scales: {
          x: {
            stacked: true,
          },
          y: {
            stacked: true
          }
        }
      }
    });
  };
  doQuery(mangas_api, onFetch);
}

async function populateSales() {
  const months = [ "January", "February", "March", "April", "May", "June", 
                   "July", "August", "September", "October", "November", "December" ];
  const onFetch = (json) => {
    console.log(json);
    const tbl = document.getElementById("sales_table");
    const templ = document.getElementById("sales_item").innerHTML;
    json.mangas.forEach((manga, idx) => {
      const element = document.createElement("tr");
      element.innerHTML = Mustache.render(templ, {
        name: months[idx],
        total: formatPrice(manga.total/100),
      });
      tbl.appendChild(element);
    });

    new Chart(document.getElementById("sales_graph"), {
      type: 'line',
      data: {
        labels: months,
        datasets: [
          {
            label: "Sales income",
            data: json.mangas.map((item) => item.total/100),
          }
        ],
      },
      options: {
        responsive: true,
        plugins: {
          legend: {
            position: 'top',
          },
          title: {
            display: true,
            text: "Income per month",
          }
        }
      },
    });
  };
  doQuery(sales_api, onFetch);
}

async function populateUsers() {
  const onFetch = (json) => {
    console.log(json);
    const tbl = document.getElementById("user_table");
    const templ = document.getElementById("user_item").innerHTML;
    json.mangas.forEach((user) => {
      const element = document.createElement("tr");
      element.innerHTML = Mustache.render(templ, {
        name: user.name,
        sales: user.sales,
        total: formatPrice(user.total),
      });
      tbl.appendChild(element);
    });

    new Chart(document.getElementById("user_graph"), {
      type: 'bar',
      data: {
        labels: json.mangas.map((manga) => manga.username),
        datasets: [
          {
            label: "User sales",
            data: json.mangas.map((item) => item.total),
          }
        ],
      },
      options: {
        plugins: {
          title: {
            display: true,
            text: 'Manga sales per user'
          },
        },
        responsive: true,
        scales: {
          x: {
            stacked: true,
          },
          y: {
            stacked: true
          }
        }
      }
    });
  };
  doQuery(users_api, onFetch);
}

populateMangas();
populateSales();
populateUsers();
