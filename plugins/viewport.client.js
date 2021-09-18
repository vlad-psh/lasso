// Mobile browsers proper height hack
// Source: https://css-tricks.com/the-trick-to-viewport-units-on-mobile/
function correctVH() {
  const vh = window.innerHeight
  document.documentElement.style.setProperty('--vh', `${vh}px`)
}
correctVH()
window.addEventListener('resize', correctVH)
