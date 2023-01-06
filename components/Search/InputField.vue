<template>
  <div>
    <SearchModeSelector
      :selected-mode="selectedMode"
      @change="(modeId) => (selectedMode = modeId)"
      @search="search"
    />

    <div class="search-field">
      <input
        ref="searchField"
        v-model="searchField"
        v-shortkey.focus="['esc']"
        type="text"
        placeholder="Search..."
        @keydown.enter="search"
        @keydown.tab.prevent="switchDictionary"
        @keydown.esc="clearInputField"
        @keydown.down="$emit('switch-candidate', 'next')"
        @keydown.up="$emit('switch-candidate', 'prev')"
      />
      <div class="clear-button" @click="clearInputField">
        <ClearIcon />
      </div>
    </div>
  </div>
</template>

<script>
import debounce from '@/js/debouncer.js'
import ClearIcon from '@/assets/icons/clear.svg?inline'

export default {
  components: { ClearIcon },
  data() {
    return {
      searchField: this.$store.state.search.query,
      searchQuery: this.$store.state.search.query, // when user press 'Enter'
      selectedMode: 'primary',
    }
  },
  // watch: {
  //   '$route.params'() {
  //     this.searchField = this.$route.params.query || ''
  //     this.searchQuery = this.$route.params.query || ''
  //   },
  // },
  mounted() {
    this.searchField = this.$route.params.query
    this.searchQuery = this.$route.params.query
    this.selectedMode = this.$store.state.search.current.mode || 'primary'
  },
  methods: {
    searchLater: debounce(function () {
      this.search()
    }, 250),
    search() {
      this.searchQuery = this.searchField
      this.$search.execute({
        query: this.searchQuery,
        popRoute: true,
        mode: this.selectedMode,
      })
    },
    clearInputField() {
      this.$store.commit('search/RESET_AXIOS_CANCEL_HANDLER')
      this.searchField = ''
      this.$refs.searchField.focus()
    },
    switchDictionary() {
      const modes = Object.keys(this.$search.modes)
      const idx = modes.findIndex((i) => i === this.selectedMode)
      this.selectedMode = modes[(idx + 1) % modes.length]
    },
  },
}
</script>

<style lang="scss" scoped>
.search-field {
  position: relative;
  border-bottom: 1px solid var(--border-color);

  input[type='text'] {
    background: none;
    border: none;
    padding: 0.4em 0.6em 0.5em 0.6em;
    box-sizing: border-box;
    width: 100%;
  }

  .clear-button {
    position: absolute;
    right: 0;
    top: 0;
    cursor: pointer;
    font-size: 1.2em;
    padding: 0.3em 0.5em;

    svg {
      height: 0.9em;
      width: 0.9em;
    }

    &:hover {
      opacity: 0.6;
    }
  }
}

@media (max-width: 568px) {
  .search-field input[type='text'] {
    font-size: 16px;
  }
}
</style>
