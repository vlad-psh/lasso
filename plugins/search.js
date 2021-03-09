import Vue from 'vue'
import kokugoDic from '@/js/sakuin/kokugo.js'
import kanjiDic from '@/js/sakuin/kanji.js'
import onomatDic from '@/js/sakuin/onomat.js'
import kanaProcess from '@/js/kana_helpers.js'

export default (context, inject) => {
  const { store, app } = context

  function searchName(params) {
    if (['kokugo', 'kanji', 'onomat'].includes(params.mode)) {
      return 'jiten'
    } else if (params.query) {
      return 'search-sub'
    } else {
      return 'index'
    }
  }

  const $search = new Vue({
    data() {
      return {
        modes: {
          primary: { title: '探す', func: this.primarySearch },
          kokugo: { title: '国語', func: this.kokugo },
          kanji: { title: '漢字', func: this.kanji },
          onomat: { title: 'ｵﾉﾏﾄ', func: this.onomat },
        },
      }
    },
    computed: {
      path() {
        return this.buildSearchPath(store.state.search.current)
      },
    },
    methods: {
      setCurrent(val) {
        store.commit('search/SET_CURRENT', val)
      },
      kanji({ query }) {
        const result = kanjiDic.find((i) => new RegExp(query).test(i))
        if (result)
          this.setCurrent({
            dict: 'kanji',
            page: Number.parseInt(result.split(' ')[0]),
            query,
          })
        return !!result
      },
      kokugo({ query }) {
        const w = kanaProcess(query)
        const wp = kokugoDic.findIndex((i) => i >= w)
        // console.log('Search result for', w, `is ${kokugoDic[wp]} > ${w}`)
        if (wp !== -1) this.setCurrent({ mode: 'kokugo', page: wp + 1, query })
        return wp !== -1
      },
      onomat({ query }) {
        const w = kanaProcess(query)
        const wp = onomatDic.findIndex((i) => i >= w)
        // console.log('Search result for', w, `is ${onomatDic[wp]} > ${w}`)
        if (wp !== -1) this.setCurrent({ mode: 'onomat', page: wp + 1, query })
        return wp !== -1
      },
      async primarySearch(params) {
        const searchResult = await store.dispatch('search/search', params.query)
        // this.$store.commit('cache/ADD_HISTORY', { type: 'word', seq })
        if (searchResult) {
          if (params.seq) store.dispatch('search/selectSeq', params.seq)
          else store.commit('search/SET_IDX', 0)
          // this.setCurrent({
          //   mode: 'primary',
          //   query: params.query,
          //   seq: store.getters['search/selectedSeq'],
          // })
          return true
        }
        return false
      },
      async execute(params) {
        const result = await this.modes[params.mode || 'primary'].func(params)
        if (result && process.browser) {
          const route = this.buildSearchPath(params)
          // TODO: possible redundant navigation (on browser back/fwd button)
          // or on NuxtLink click
          if (params.popRoute) app.router.push(route)
          else app.router.replace(route)
        }
      },
      async fromRoute(route) {
        await this.execute({
          mode: route.params.mode || 'primary',
          query: route.params.query,
          seq: route.params.seq,
        })
      },
      buildSearchPath(params) {
        return { name: searchName(params), params }
      },
    },
  })

  inject('search', $search)
}
