export const state = () => ({
  device: 'pc',
  user: undefined, // undefined || null || User object
  activityGroup: 'other',
  quizParams: null,
})

export const mutations = {
  SET_USER(state, val) {
    state.user = val
  },
  SET_ACTIVITY_GROUP(state, val) {
    state.activityGroup = val
  },
  SET_QUIZ_PARAMS(state, val) {
    state.quizParams = val
  },
}
