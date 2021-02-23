export default (context, inject) => {
  const { store, redirect, $axios } = context
  inject('auth', {
    async getSession() {
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
      redirect('/login')
    },
    async login({ username, password }) {
      try {
        const resp = await $axios.post('/api/session', {
          username,
          password,
        })
        store.commit('env/SET_USER', resp.data)
      } catch {}
      redirect('/')
    },
  })
  context.$auth.getSession()
}
