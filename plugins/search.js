import Vue from 'vue'

export default (context, inject) => {
  const { store, app } = context

  function searchName(params) {
    if (params.query && params.seq) {
      return 'search-query-seq'
    } else if (params.query) {
      return 'search-query'
    } else {
      return 'index'
    }
  }

  const $search = new Vue({
    computed: {
      path() {
        return this.buildSearchPath({
          query: store.state.search.query,
          seq: store.getters['search/selectedSeq'],
        })
      },
    },
    methods: {
      async execute(params) {
        const searchResult = await store.dispatch('search/search', params.query)
        // this.$store.commit('cache/ADD_HISTORY', { type: 'word', seq })
        if (searchResult) {
          if (process.browser) {
            const route = this.buildSearchPath(params)
            // TODO: possible redundant navigation (on browser back/fwd button)
            // or on NuxtLink click
            if (params.popRoute) app.router.push(route)
            else app.router.replace(route)
          }

          if (params.seq) store.dispatch('search/selectSeq', params.seq)
          else store.commit('search/SET_IDX', 0)
        }
      },
      buildSearchPath(params) {
        return { name: searchName(params), params }
      },
    },
  })

  inject('search', $search)
}
