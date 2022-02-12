import Vue from 'vue'

export default (context, inject) => {
  const { store, $axios } = context

  const $auth = new Vue({
    computed: {
      loggedIn() {
        const user = store.state.env.user
        if (typeof user === 'undefined') return undefined
        else return !!user
      },
    },
    async created() {
      try {
        const resp = await $axios.get('/api/session')
        store.commit('env/SET_USER', resp.data)
      } catch {
        store.commit('env/SET_USER', null)
      }
    },
    methods: {
      async logout() {
        try {
          await $axios.delete('/api/session')
          store.commit('env/SET_USER', null)
        } catch {}
      },
      async login({ username, password }) {
        try {
          const resp = await $axios.post('/api/session', {
            username,
            password,
          })
          store.commit('env/SET_USER', resp.data)
        } catch {}
      },
    },
  })

  inject('auth', $auth)
}
