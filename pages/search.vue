<template>
  <div id="search-app">
    <div class="browse-panel">
      <div class="search-field">
        <input
          v-model="searchQuery"
          v-shortkey.focus="['esc']"
          type="text"
          placeholder="Search..."
          autofocus
          @keydown.enter="search"
          @keydown.tab.prevent="switchDictionary"
          @keydown.esc="clearInputField"
          @keydown.down="switchCandidate('next')"
          @keydown.up="switchCandidate('prev')"
        />
      </div>
      <div class="search-mode">
        <div
          v-for="(d, dIdx) of dicts"
          :key="'dict' + dIdx"
          :class="[d.id, dictIndex === dIdx ? 'selected' : null]"
          @click="dictIndex = dIdx"
        >
          {{ d.title }}
        </div>
      </div>
      <div class="search-results">
        <SearchCandidateItem
          v-for="(item, index) in $store.state.search.results"
          :key="item[0]"
          ref="candidates"
          :item="item"
          :is-selected="index === $store.state.search.selectedIdx"
          :on-click="selectCandidate"
        />
      </div>
    </div>
    <div class="contents-panel">
      <Word
        v-if="$store.state.search.selected"
        :key="$store.state.search.selected.seq"
        :seq="$store.state.search.selected.seq"
      />
      <ImageView />
    </div>
  </div>
</template>

<script>
import debounce from '@/js/debouncer.js'

export default {
  middleware: (ctx) => {
    ctx.store.commit('env/SET_ACTIVITY_GROUP', 'search')
  },
  async fetch() {
    const { route } = this.$nuxt.context
    if (process.server) this.searchQuery = route.params.query
    await this.$search.execute(route.params)
  },
  data() {
    // FIX until https://github.com/nuxt/nuxt.js/pull/5188/files/85ec562c6bdfff6ff97fcb9a8a95c2747b56ee31 is clarified
    if (this.$data) return this.$data

    return {
      searchQuery: this.$store.state.search.query,
      dicts: [
        { id: 'jmdict', title: '探す' },
        { id: 'kokugo', title: '国語' },
        { id: 'kanji', title: '漢字' },
        { id: 'onomat', title: 'ｵﾉﾏﾄ' },
      ],
      dictIndex: 0,
    }
  },
  computed: {
    dictionary() {
      return this.dicts[this.dictIndex]
    },
  },
  watch: {
    '$route.params'() {
      this.searchQuery = this.$route.params.query || ''
    },
  },
  mounted() {
    // onpopstate invokes only when we're going back/fwd in browser's history
    // and doesn't invokes at $router.push() etc
    // That's why we're using it instead of just watching for '$route.query'
    window.onpopstate = () => {
      // We don't have access to updated $route.query yet (onpopstate)
      const params = this.$router.match(location.pathname).params
      this.$search.execute(params)
    }
    this.scrollToIndex(this.$store.state.search.selectedIdx)
  },
  methods: {
    searchLater: debounce(function () {
      this.search()
    }, 250),
    search() {
      this.$search.execute({
        query: this.searchQuery,
        popRoute: true,
        dict: this.dictionary.id,
      })
    },
    selectCandidate(seq) {
      this.$search.execute({ query: this.searchQuery, seq })
    },
    switchCandidate(direction) {
      const results = this.$store.state.search.results
      let idx = this.$store.state.search.selectedIdx
      if (direction === 'prev' && idx > 0) idx--
      else if (direction === 'next' && idx < results.length) idx++
      this.selectCandidate(results[idx][0])
      this.scrollToIndex(idx)
    },
    scrollToIndex(idx) {
      if (!this.$refs.candidates) return
      this.$refs.candidates[idx].$el.scrollIntoView({
        behavior: 'smooth',
        block: 'nearest',
        inline: 'nearest',
      })
    },
    clearInputField() {
      this.$store.commit('search/RESET_AXIOS_CANCEL_HANDLER')
      this.searchQuery = ''
    },
    switchDictionary() {
      this.dictIndex = (this.dictIndex + 1) % this.dicts.length
    },
  },
  head() {
    return { title: this.searchQuery }
  },
}
</script>

<style lang="scss"></style>
