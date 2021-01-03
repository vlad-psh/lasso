<template>
  <div id="search-app">
    <div class="browse-panel">
      <div class="search-field">
        <input
          v-model="searchQuery"
          type="text"
          placeholder="Search..."
          @input="pushRouteLater()"
          @keydown.enter="pushRoute()"
          @keydown.esc="clearInputField()"
          @keydown.down="nextCandidate()"
          @keydown.up="previousCandidate()"
        />
      </div>
      <div class="search-results">
        <CandidateItem
          v-for="(item, index) in $store.state.search.results"
          :key="item[0]"
          :item="item"
          :index="index"
          :is-selected="index === $store.state.search.selectedIdx"
          :on-click="selectCandidate"
        />
      </div>
    </div>
    <div class="contents-panel">
      <Word
        v-for="seq of $store.state.cache.wordIds"
        :key="seq"
        :seq="seq"
      ></Word>
    </div>
  </div>
</template>

<script>
import debounce from '@/js/debouncer.js'

export default {
  async middleware(ctx) {
    // Store isn't accesible inside fetch, that's why we're using middleware
    // https://github.com/nuxt/nuxt.js/issues/7232
    const { store, query } = ctx
    await store.dispatch('search/search', {
      query: query.query,
      index: Number.parseInt(query.index),
    })
    await store.dispatch('cache/loadWord', store.state.search.selectedSeq)
  },
  data() {
    return {
      searchQuery: this.$store.state.search.query,
    }
  },
  computed: {},
  mounted() {
    // onpopstate invokes only when we're going back/fwd in browser's history
    // It doesn't invokes after calling '$router.push' manually
    window.onpopstate = () => {
      // We don't have access to updated $route.query yet (onpopstate)
      const u = new URLSearchParams(location.search)
      this.searchQuery = u.get('query') || ''
    }
  },
  methods: {
    pushRouteLater: debounce(function () {
      this.pushRoute()
    }, 250),
    pushRoute() {
      this.$router.push({ query: { query: this.searchQuery } })
      document.title = this.searchQuery
    },
    replaceRoute() {
      this.$router.replace({
        query: {
          query: this.searchQuery,
          index: this.$store.state.search.selectedIdx,
        },
      })
    },
    nextCandidate() {
      this.$store.commit('search/SEL_IDX_INCR')
      this.replaceRoute()
    },
    previousCandidate() {
      this.$store.commit('search/SEL_IDX_DECR')
      this.replaceRoute()
    },
    selectCandidate(idx) {
      this.$store.commit('search/SELECT_IDX', idx)
      this.replaceRoute()
      // TODO: Scroll to word
    },
    clearInputField() {
      this.$store.commit('search/RESET_AXIOS_CANCEL_HANDLER')
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

  .contents-panel {
    height: 100%;
    overflow-y: auto;
  }
}
</style>
