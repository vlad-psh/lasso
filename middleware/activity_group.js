export default ({ store }) => {
  // (re)set default activity group for every page
  store.commit('env/SET_ACTIVITY_GROUP', 'other')
}
