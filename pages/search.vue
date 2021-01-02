<template>
  <div id="search-app">
    <div class="browse-panel">
      <div class="search-field">
        <input
          v-model="searchQuery"
          type="text"
          placeholder="Search..."
          @input="$store.dispatch('search/searchDebounce', searchQuery)"
          @keydown.enter="$store.dispatch('search/search', searchQuery)"
        />
        <div
          v-if="$store.state.search.axiosSearchToken"
          class="loading-circles"
        >
          <div></div>
          <div></div>
          <div></div>
        </div>
      </div>
      <div class="search-results">
        <CandidateItem
          v-for="result in $store.state.search.searchResults"
          :key="result[0]"
          :result="result"
        />
      </div>
    </div>
    <ContentsPanel />
  </div>
</template>

<script>
export default {
  async middleware({ store, query, $axios }) {
    // Store isn't accesible inside fetch, that's why we're using middleware
    // https://github.com/nuxt/nuxt.js/issues/7232
    const queryStr = query.query
    if (!queryStr) return
    const { data } = await $axios.post('/api/search', { query: queryStr })
    store.commit('search/SET_RESULTS', { query: queryStr, results: data })
  },
  data() {
    return {
      searchQuery: this.$store.state.search.previousQuery,
    }
  },
  computed: {},
  mounted() {},
  methods: {},
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
      .loading-circles {
        position: absolute;
        right: 1em;
        top: 0.8em;
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
