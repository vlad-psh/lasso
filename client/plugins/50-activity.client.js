export default defineNuxtPlugin(async (_nuxtApp) => {
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
    const env = useEnv()
    const aGroup = env.activityGroup
    storage[aGroup] = (storage[aGroup] || 0) + 1
    if (storage[aGroup] === submitInterval) {
      $fetch(`/api/activity/${aGroup}/${submitInterval}`, {
        method: 'POST',
        credentials: 'same-origin'
      })
        .then(() => storage[aGroup] = 0)
        .catch((e) => {
          if (e.status !== 405) console.error(e)
        })
    }
  }
})
