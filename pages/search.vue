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

<style lang="scss" scoped>
#search-app {
  display: grid;
  grid-template-columns: clamp(10em, 25vw, 22em) 1fr;
  grid-template-rows: 100%;
  overflow: hidden;

  .browse-panel {
    border: 0px solid var(--border-color);
    border-right-width: 1px;
    height: 100%;
    display: grid;
    grid-template-rows: auto auto 1fr;

    .search-results {
      height: 100%;
      overflow-y: auto;
      overflow-x: hidden;
    }
  }

  .contents-panel {
    height: 100%;
    overflow-y: auto;
  }
}

@media (max-width: 568px) {
  #search-app {
    grid-template-columns: 1fr 10em;

    .browse-panel {
      grid-row: 1;
      grid-column: 2;
      border-right-width: 0;
      border-left-width: 1px;
    }
    .contents-panel {
      grid-row: 1;
      grid-column: 1;
      font-size: 1em;
    }
  }
}
</style>
