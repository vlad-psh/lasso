export default defineNuxtRouteMiddleware((to, _from) => {
  const env = useEnv()
  // When navigated to "unknown" page (the page, which does not explicitly set
  // 'activityGroup' on mounting), we need to make sure, that 'activityGroup'
  // value automatically reset.
  //
  // Some pages are added as exceptions because they're set 'activityGroup'
  // on mount, but do not touch it again if we, for example, changed search
  // query. So we need not to reset 'activityGroup' in this case.
  if (!['search', 'jiten'].includes(to.name)) {
    env.setActivityGroup('other')
  }
})
