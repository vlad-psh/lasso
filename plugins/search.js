import Vue from 'vue'
import kokugoDic from '@/js/sakuin/kokugo.js'
import kanjiDic from '@/js/sakuin/kanji.js'
import onomatDic from '@/js/sakuin/onomat.js'
import kanaProcess from '@/js/kana_helpers.js'

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
    data: {
      current: null,
    },
    computed: {
      path() {
        return this.buildSearchPath({
          query: store.state.search.query,
          seq: store.getters['search/selectedSeq'],
        })
      },
    },
    methods: {
      kanji({ query }) {
        const result = kanjiDic.find((i) => new RegExp(query).test(i))
        if (result)
          this.current = {
            book: 'kanji',
            page: Number.parseInt(result.split(' ')[0]),
            query,
          }
      },
      kokugo({ query }) {
        const w = kanaProcess(query)
        const wp = kokugoDic.findIndex((i) => i >= w)
        // console.log('Search result for', w, `is ${kokugoDic[wp]} > ${w}`)
        if (wp !== -1) this.current = { book: 'kokugo', page: wp + 1, query }
      },
      onomat({ query }) {
        const w = kanaProcess(query)
        const wp = onomatDic.findIndex((i) => i >= w)
        // console.log('Search result for', w, `is ${onomatDic[wp]} > ${w}`)
        if (wp !== -1) this.current = { book: 'onomat', page: wp + 1, query }
      },
      async jmdict(params) {
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
      async execute(params) {
        await this[params.dict || 'jmdict'](params)
      },
      buildSearchPath(params) {
        return { name: searchName(params), params }
      },
    },
  })

  inject('search', $search)
}
