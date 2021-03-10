export default ({ store, route }) => {
  // (re)set default activity group for every page
  if (!['index', 'search-sub', 'jiten'].includes(route.name)) {
    store.commit('env/SET_ACTIVITY_GROUP', 'other')
  }
}
