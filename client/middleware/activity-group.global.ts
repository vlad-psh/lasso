export default defineNuxtRouteMiddleware((to, _from) => {
  const env = useEnv()
  // (re)set default activity group for every page
  if (!['index', 'sub-search', 'jiten'].includes(to.name)) {
    env.setActivityGroup('other')
  }
})
