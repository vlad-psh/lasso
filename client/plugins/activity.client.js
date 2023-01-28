export default ({ store }, inject) => {
  const startEvents = [
    'load',
    'mousedown',
    'mousemove',
    'keydown',
    'scroll',
    'touchstart',
  ]
  const submitInterval = 30
  const storage = {}
  let active // active interval
  let idle // idle timeout
  let idleTS = new Date() - 5000

  for (const e of startEvents) window.addEventListener(e, start, true)
  document.addEventListener('visibilitychange', () => {
    if (document.visibilityState === 'visible') start()
  })

  function start() {
    if (!active) {
      active = setInterval(tick, 1000)
    }
    if (new Date() - idleTS > 1000) {
      idleTS = new Date()
      clearTimeout(idle)
      idle = setTimeout(() => {
        clearInterval(active)
        active = null
      }, 5000)
    }
  }
  function tick() {
    const aGroup = store.state.env.activityGroup
    storage[aGroup] = (storage[aGroup] || 0) + 1
    if (storage[aGroup] === submitInterval) {
      const submitUrl = `/api/activity/${aGroup}/${submitInterval}`
      fetch(submitUrl, { method: 'POST', credentials: 'same-origin' })
      storage[aGroup] = 0
    }
  }
}
