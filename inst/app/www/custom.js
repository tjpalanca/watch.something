function setVerticalHeight() {
  let vh = window.innerHeight * 0.01;
  document.documentElement.style.setProperty('--vh', `${vh}px`);
}

setVerticalHeight();

window.addEventListener('resize', () => {
  setVerticalHeight();
});
