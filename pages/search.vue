<template>
  <div id="search-app">
    <div class="browse-panel">
      <div class="search-field">
        <input
          v-model="searchQuery"
          type="text"
          placeholder="Search..."
          @input="pushSearchQueryLater()"
          @keydown.enter="pushSearchQuery()"
          @keydown.esc="clearInputField()"
          @keydown.down="nextResult()"
          @keydown.up="previousResult()"
        />
        <LoadingCircles v-if="$store.state.search.axiosCancelHandler" />
      </div>
      <div class="search-results">
        <CandidateItem
          v-for="(item, index) in $store.state.search.searchResults"
          :key="item[0]"
          :item="item"
          :is-selected="index === $store.state.search.highlightedWordIndex"
        />
      </div>
    </div>
    <ContentsPanel />
  </div>
</template>

<script>
import debounce from '@/js/debouncer.js'

export default {
  async middleware({ store, query }) {
    // Store isn't accesible inside fetch, that's why we're using middleware
    // https://github.com/nuxt/nuxt.js/issues/7232
    await store.dispatch('search/search', {
      query: query.query,
      index: Number.parseInt(query.index),
    })
  },
  data() {
    return {
      searchQuery: this.$store.state.search.previousQuery,
      historyTransition: false,
    }
  },
  computed: {},
  watch: {
    $route(to, from) {
      // We only need to update searchQuery only if we're going back/fwd in browser's history
      // (see 'window.onpopstate' in mounted() hook)
      // We don't need to update after calling '$router.push' manually
      if (this.historyTransition === true) {
        this.historyTransition = false
        this.searchQuery = to.query.query || ''
        document.title = this.searchQuery
      }
    },
  },
  mounted() {
    window.onpopstate = () => (this.historyTransition = true)
  },
  methods: {
    pushSearchQueryLater: debounce(function () {
      this.pushSearchQuery()
    }, 250),
    pushSearchQuery() {
      this.$router.push({ query: { query: this.searchQuery } })
      document.title = this.searchQuery
    },
    replaceSearchQuery() {
      this.$router.replace({
        query: {
          query: this.searchQuery,
          index: this.$store.state.search.highlightedWordIndex,
        },
      })
    },
    nextResult() {
      this.$store.commit('search/SEL_IDX_INCR')
      this.replaceSearchQuery()
      // this.openWordDebounced()
    },
    previousResult() {
      this.$store.commit('search/SEL_IDX_DECR')
      this.replaceSearchQuery()
      // this.openWordDebounced()
    },
    clearInputField() {
      // TODO: cancel current search request
      this.searchQuery = ''
    },
  },
}
</script>

<style lang="scss">
$borderColor: rgba(192, 192, 192, 0.3);
#search-app {
  height: calc(100vh - 33px);
  display: grid;
  grid-template-columns: 22em 1fr;
  grid-template-rows: 100%;

  .browse-panel {
    border: 0px solid $borderColor;
    border-right-width: 1px;
    height: 100%;
    display: grid;
    grid-template-rows: auto 1fr;

    .search-field {
      position: relative;

      input[type='text'] {
        background: none;
        border: none;
        border-bottom: 1px solid $borderColor;
        padding: 0.4em 0.6em 0.5em 0.6em;
        box-sizing: border-box;
        width: 100%;
      }
    }
    .search-results {
      height: 100%;
      overflow-y: auto;
      background: #f7f7f7;
    }
  } // .browse-panel
}

@keyframes blink-highlight {
  from {
    background-color: rgba(255, 255, 0, 0.3);
  }
  to {
    background-color: transparent;
  }
}
</style>
