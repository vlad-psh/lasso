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
          @input="searchLater"
          @keydown.enter="search"
          @keydown.esc="clearInputField"
          @keydown.down="switchCandidate('next')"
          @keydown.up="switchCandidate('prev')"
        />
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
    const { store, route } = this.$nuxt.context
    if (process.server) this.searchQuery = route.params.query
    await store.dispatch('search/search', route.params)
  },
  data() {
    // FIX until https://github.com/nuxt/nuxt.js/pull/5188/files/85ec562c6bdfff6ff97fcb9a8a95c2747b56ee31 is clarified
    if (this.$data) return this.$data

    return { searchQuery: this.$store.state.search.query }
  },
  computed: {},
  watch: {
    '$route.params': '$fetch',
  },
  mounted() {
    // onpopstate invokes only when we're going back/fwd in browser's history
    // and doesn't invokes at $router.push() etc
    // That's why we're using it instead of just watching for '$route.query'
    window.onpopstate = () => {
      // We don't have access to updated $route.query yet (onpopstate)
      const u = new URLSearchParams(location.search)
      this.searchQuery = u.get('query') || ''
      this.$store.dispatch('search/search', {
        query: this.searchQuery,
        seq: u.get('seq'),
      })
    }
    this.scrollToIndex(this.$store.state.search.selectedIdx)
  },
  methods: {
    searchLater: debounce(function () {
      this.search()
    }, 250),
    search() {
      this.$router.push(
        this.$query.buildSearchPath({ query: this.searchQuery })
      )
    },
    selectCandidate(seq) {
      if (this.$store.getters['search/selectedSeq'] !== seq) {
        this.$store.dispatch('search/selectSeq', seq)
        this.$store.commit('cache/ADD_HISTORY', { type: 'word', seq })
        this.$router.replace(
          this.$query.buildSearchPath({
            query: this.$store.state.search.query,
            seq,
          })
        )
      }
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
  },
  head() {
    return { title: this.searchQuery }
  },
}
</script>

<style lang="scss"></style>
