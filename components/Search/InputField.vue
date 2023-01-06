<template>
  <div class="search-field">
    <SearchModeSelector
      :selected-mode="selectedMode"
      @change="(modeId) => (selectedMode = modeId)"
      @search="search"
    />

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
      // this.searchField = ''
      this.$refs.searchField.focus()
      this.$refs.searchField.select()
    },
    switchDictionary() {
      const modes = this.$search.modes.map((i) => i.id)
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
  padding: 0.4em 0.5em 0.5em;

  input[type='text'] {
    background: none;
    border: none;
    padding: 0.2em 0.6em 0.2em 2.4em;
    box-sizing: border-box;
    width: 100%;
    border-radius: 0.4em;
    box-shadow: inset 0 2px 4px 0 rgba(0, 0, 0, 0.05);
    border: 1px solid rgb(229 231 235);
  }

  .clear-button {
    position: absolute;
    right: 0.3em;
    top: calc(50% - 0.8em);
    cursor: pointer;
    font-size: 1em;
    line-height: 1em;
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
