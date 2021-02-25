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
          @keydown.down="selectCandidate('incr')"
          @keydown.up="selectCandidate('decr')"
        />
      </div>
      <div class="search-results">
        <SearchCandidateItem
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
      <div class="tear-line" />
    </div>
  </div>
</template>

<script>
import debounce from '@/js/debouncer.js'

export default {
  middleware: [
    'auth',
    ({ store }) => {
      store.commit('env/SET_ACTIVITY_GROUP', 'search')
    },
  ],
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
        index: 0,
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
        index: 0,
      })
      this.$router.push({ query: { query: this.searchQuery } })
    },
    selectCandidate(idx) {
      this.$store.dispatch('search/selectIndex', idx)
      this.$router.replace({
        query: {
          query: this.searchQuery,
          index: this.$store.state.search.selectedIdx,
        },
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

<style lang="scss">
#search-app {
  display: grid;
  grid-template-columns: 22em 1fr;
  grid-template-rows: 100%;
  overflow: hidden;

  .browse-panel {
    border: 0px solid var(--border-color);
    border-right-width: 1px;
    height: 100%;
    display: grid;
    grid-template-rows: auto 1fr;

    .search-field {
      position: relative;

      input[type='text'] {
        background: none;
        border: none;
        border-bottom: 1px solid var(--border-color);
        padding: 0.4em 0.6em 0.5em 0.6em;
        box-sizing: border-box;
        width: 100%;
      }
    }
    .search-results {
      height: 100%;
      overflow-y: auto;
      overflow-x: clip;
      background: #0001;
    }
  } // .browse-panel

  .contents-panel {
    height: 100%;
    overflow-y: auto;
  }
}

@media (max-width: 568px) {
  body {
    #search-app {
      grid-template-columns: 1fr 10em;
      // height: calc(100vh - 33px); // fallback value
      // Proper height: https://css-tricks.com/the-trick-to-viewport-units-on-mobile/
      // --vh value is calculated in javascript on search page
      // height: calc(var(--vh, 1vh) * 100 - 33px);

      .browse-panel {
        grid-row: 1;
        grid-column: 2;
        border-right-width: 0;
        border-left-width: 1px;

        .search-results .candidate-item {
          padding: 0.12em 0.2em;
          .title {
            font-size: 0.9em;
            .common-icon,
            .learned-icon {
              font-size: 0.7em;
            }
          }
          .details {
            width: 14em;
            padding-left: 0;
            font-size: 0.7em;
          }
        }
        .search-method {
          font-size: 0.8em;
        }
      }
      .contents-panel {
        grid-row: 1;
        grid-column: 1;
        font-size: 1em;
      }
    }
  }
}
</style>
