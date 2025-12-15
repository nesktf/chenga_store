const is_open_class = "modal-is-open";
const opening_class = "modal-is-opening";
const closing_class = "modal-is-closing";
const scrollbar_width_css = "--pico-scrollbar-width";
const anim_duration = 400;
let visible_modal = null;

const get_scrollbar_width = () => {
  return window.innerWidth - document.documentElement.clientWidth;
}

const is_scrollbar_visible = () => {
  return document.body.scrollHeight > screen.height;
}

const open_modal = (modal) => {
  const { documentElement: html } = document;
  const scrollbar_width = get_scrollbar_width();
  if (scrollbar_width) {
    html.style.setProperty(scrollbar_width_css, `${scrollbar_width}px`);
  }
  html.classList.add(is_open_class, opening_class);
  setTimeout(() => {
    visible_modal = modal;
    html.classList.remove(opening_class);
  }, anim_duration);
  modal.showModal();
}

const close_modal = (modal) => {
  visible_modal = null;
  const { documentElement: html } = document;
  html.classList.add(closing_class);
  setTimeout(() => {
    html.classList.remove(closing_class, is_open_class);
    html.style.removeProperty(scrollbar_width_css);
    modal.close();
  }, anim_duration);
}

const toggle_modal = (event) => {
  event.preventDefault();
  const modal = document.getElementById(event.currentTarget.dataset.target);
  console.log(event);
  if (!modal) {
    return;
  }
  modal && (modal.open ? close_modal(modal) : open_modal(modal));
}

document.addEventListener("click", (event) => {
  if (visible_modal === null) {
    return;
  }

  const modal_content = visible_modal.querySelector("article");
  !modal_content.contains(event.target) && close_modal(visible_modal);
})

document.addEventListener("keydown", (event) => {
  if (event.key === "Escape" && visible_modal !== null) {
    close_modal(visible_modal);
  }
})
