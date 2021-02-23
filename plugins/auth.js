export default async (context, inject) => {
  const { store, $axios, next } = context
  inject('auth', {
    async getSession() {
      if (store.state.env.user) return
      try {
        const resp = await $axios.get('/api/session')
        store.commit('env/SET_USER', resp.data)
      } catch {
        store.commit('env/SET_USER', null)
      }
    },
    async logout() {
      try {
        await $axios.delete('/api/session')
        store.commit('env/SET_USER', null)
      } catch {}
      next('/login')
    },
    async login({ username, password }) {
      try {
        const resp = await $axios.post('/api/session', {
          username,
          password,
        })
        store.commit('env/SET_USER', resp.data)
      } catch {}
      next('/')
    },
  })
  await context.$auth.getSession()
}
