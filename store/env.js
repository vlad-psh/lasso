export const state = () => ({
  device: 'pc',
  user: null,
  activityGroup: 'other',
})

export const mutations = {
  SET_USER(state, val) {
    state.user = val
  },
  SET_ACTIVITY_GROUP(state, val) {
    state.activityGroup = val
  },
}
