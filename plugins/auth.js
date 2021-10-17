import Vue from 'vue'

export default (context, inject) => {
  const { store, $axios, next, route, redirect } = context

  const $auth = new Vue({
    async created() {
      try {
        const resp = await $axios.get('/api/session')
        store.commit('env/SET_USER', resp.data)
        if (['login'].includes(route.name)) redirect(302, '/')
      } catch {
        store.commit('env/SET_USER', false)
        if (!['login'].includes(route.name)) redirect(302, '/login')
      }
    },
    methods: {
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
      loggedIn() {
        return !!store.state.env.user
      },
    },
  })

  inject('auth', $auth)
}
