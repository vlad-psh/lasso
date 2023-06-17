export default defineNuxtPlugin(async (_nuxtApp) => {
  const store = useEnv()
  try {
    const resp = await $fetch('/api/session')
    store.setUser(JSON.parse(resp))
  } catch {
    store.setUser(undefined)
  }
})
