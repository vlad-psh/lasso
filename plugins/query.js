import Vue from 'vue'

export default (context, inject) => {
  const { store } = context

  const $query = new Vue({
    computed: {
      searchPath() {
        const q = new URLSearchParams({
          query: store.state.search.query,
          seq: store.getters['search/selectedSeq'],
        })
        return `/?${q.toString()}`
      },
    },
  })

  inject('query', $query)
}
