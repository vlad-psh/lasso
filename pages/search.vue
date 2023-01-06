<template>
  <div id="search-app">
    <div class="browse-panel">
      <SearchInputField
        @switch-candidate="(direction) => switchCandidate(direction)"
      />

      <div class="search-results">
        <SearchCandidateItem
          v-for="(item, itemIndex) in $store.state.search.results"
          :key="`candidate-${itemIndex}`"
          ref="candidates"
          :item="item"
          :is-selected="item[0] === current.seq"
          :on-click="selectCandidate"
        />
      </div>
    </div>
    <div class="contents-panel">
      <WordComponent v-if="currentMode === 'primary'" :seq="current.seq" />
      <JitenImage v-else-if="currentMode === 'jiten'" :payload="current" />
    </div>
  </div>
</template>

<script>
export default {
  async fetch() {
    const { route } = this.$nuxt.context
    await this.$search.fromRoute(route)
  },
  computed: {
    current() {
      return this.$store.state.search.current
    },
    currentMode() {
      if (this.current.mode)
        return this.current.mode === 'primary' ? 'primary' : 'jiten'
      return null
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
    this.$nextTick(() =>
      this.scrollToIndex(this.$store.getters['search/currentIndex'])
    )
  },
  methods: {
    selectCandidate(seq) {
      this.$search.execute({ seq })
    },
    switchCandidate(direction) {
      const results = this.$store.state.search.results
      let idx = results.findIndex((i) => i[0] === this.current.seq)
      if (direction === 'prev' && idx > 0) idx--
      else if (direction === 'next' && idx + 1 < results.length) idx++
      this.selectCandidate(results[idx][0])
      this.scrollToIndex(idx)
    },
    scrollToIndex(idx) {
      if (!(this.$refs.candidates && this.$refs.candidates[idx])) return
      this.$refs.candidates[idx].$el.scrollIntoView({
        behavior: 'smooth',
        block: 'nearest',
        inline: 'nearest',
      })
    },
  },
}
</script>

<style lang="scss"></style>
