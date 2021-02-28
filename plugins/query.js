import Vue from 'vue'

export default (context, inject) => {
  const { store } = context

  function searchName(params) {
    if (params.query && params.seq) {
      return 'search-query-seq'
    } else if (params.query) {
      return 'search-query'
    } else {
      return 'index'
    }
  }

  const $query = new Vue({
    computed: {
      searchPath() {
        const params = {
          query: store.state.search.query,
          seq: store.getters['search/selectedSeq'],
        }
        return this.buildSearchPath(params)
      },
    },
    methods: {
      buildSearchPath(params) {
        return { name: searchName(params), params }
      },
    },
  })

  inject('query', $query)
}
