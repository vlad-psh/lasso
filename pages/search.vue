<template>
  <div id="search-app">
    <div class="browse-panel">
      <div class="search-field">
        <input
          ref="searchField"
          v-model="searchQuery"
          v-shortkey.focus="['esc']"
          type="text"
          placeholder="Search..."
          @keydown.enter="search"
          @keydown.tab.prevent="switchDictionary"
          @keydown.esc="clearInputField"
          @keydown.down="switchCandidate('next')"
          @keydown.up="switchCandidate('prev')"
        />
        <div class="clear-button" @click="clearInputField">
          <ClearIcon />
        </div>
      </div>
      <div class="search-mode">
        <div
          v-for="(mode, modeId) of $search.modes"
          :key="'dict-' + modeId"
          :class="[modeId, modeId === selectedMode ? 'selected' : null]"
          @click="searchModeClick(modeId)"
        >
          {{ mode.title }}
        </div>
      </div>
      <div class="search-results">
        <SearchCandidateItem
          v-for="item in $store.state.search.results"
          :key="$store.state.search.query + item[0]"
          ref="candidates"
          :item="item"
          :is-selected="item[0] === current.seq"
          :on-click="selectCandidate"
        />
      </div>
    </div>
    <div class="contents-panel">
      <Word
        v-if="currentMode === 'primary'"
        :key="current.seq"
        :seq="current.seq"
      ></Word>
      <ImageView
        v-else-if="currentMode === 'jiten'"
        :payload="current"
      ></ImageView>
    </div>
  </div>
</template>

<script>
import debounce from '@/js/debouncer.js'
import ClearIcon from '@/assets/icons/clear.svg?inline'

export default {
  components: { ClearIcon },
  async fetch() {
    const { route, store } = this.$nuxt.context
    // if (process.server)
    this.searchQuery = route.params.query
    await this.$search.fromRoute(route)
    this.selectedMode = store.state.search.current.mode || 'primary'
  },
  data() {
    return {
      searchQuery: this.$store.state.search.query,
      selectedMode: 'primary',
    }
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
    this.$nextTick(() =>
      this.scrollToIndex(this.$store.getters['search/currentIndex'])
    )
  },
  methods: {
    searchLater: debounce(function () {
      this.search()
    }, 250),
    search() {
      this.$search.execute({
        query: this.searchQuery,
        popRoute: true,
        mode: this.selectedMode,
      })
    },
    selectCandidate(seq) {
      this.$search.execute({ query: this.searchQuery, seq })
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
    clearInputField() {
      this.$store.commit('search/RESET_AXIOS_CANCEL_HANDLER')
      this.searchQuery = ''
      this.$refs.searchField.focus()
    },
    switchDictionary() {
      const modes = Object.keys(this.$search.modes)
      const idx = modes.findIndex((i) => i === this.selectedMode)
      this.selectedMode = modes[(idx + 1) % modes.length]
    },
    searchModeClick(modeId) {
      if (this.selectedMode === modeId) this.search()
      else this.selectedMode = modeId
    },
  },
  head() {
    return { title: this.searchQuery }
  },
}
</script>

<style lang="scss"></style>
