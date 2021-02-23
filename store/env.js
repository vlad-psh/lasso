export const state = () => ({
  device: 'pc',
  user: null,
})

export const mutations = {
  SET_USER(state, val) {
    state.user = val
  },
}
