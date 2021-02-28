<template>
  <div id="search-app">
    <div class="browse-panel">
      <div class="search-field">
        <input
          v-model="searchQuery"
          v-shortkey.focus="['esc']"
          type="text"
          placeholder="Search..."
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
    // if (process.server) {
    this.searchQuery = route.params.query
    await store.dispatch('search/search', route.params)
  },
  data() {
    return {
      searchQuery: this.$store.state.search.query,
    }
  },
  computed: {},
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
  },
  methods: {
    searchLater: debounce(function () {
      this.search()
    }, 250),
    search() {
      this.$store.dispatch('search/search', {
        query: this.searchQuery,
      })
      this.$router.push(
        this.$query.buildSearchPath({ query: this.searchQuery })
      )
    },
    selectCandidate(seq) {
      if (this.$store.getters['search/selectedSeq'] !== seq) {
        this.$store.dispatch('search/selectSeq', seq)
        this.$store.commit('cache/ADD_HISTORY', { type: 'word', seq })
        this.$router.replace(
          this.$query.buildSearchPath({ query: this.searchQuery, seq })
        )
      }
    },
    switchCandidate(direction) {
      const results = this.$store.state.search.results
      let idx = this.$store.state.search.selectedIdx
      if (direction === 'prev' && idx > 0) idx--
      else if (direction === 'next' && idx < results.length) idx++
      this.selectCandidate(results[idx][0])
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
