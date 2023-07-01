<template>
  <div class="search-field">
    <SearchModeSelector
      :selected-mode="selectedMode"
      @change="(modeId) => (selectedMode = modeId)"
      @search="emitSearch"
    />

    <div class="input-wrapper">
      <input
        class="shortkey-enabled"
        ref="searchFieldRef"
        v-model="searchField"
        disabled-v-shortkey="{
          focus: ['esc'],
          nextCandidate: ['arrowdown'],
          prevCandidate: ['arrowup'],
        }"
        type="text"
        placeholder="Search..."
        @shortkey="shortkey"
        @keydown.enter="emitSearch"
        @keydown.tab.prevent="switchDictionary"
      />
      <div class="clear-button" @click="clearInputField">
        <ClearIcon />
      </div>
    </div>

    <JitenNavigation v-if="selectedMode !== 'primary'" />
  </div>
</template>

<script setup>
  import debounce from '@/js/debouncer.js'
  import ClearIcon from '../../assets/icons/clear.svg'

  const store = useSearch()
  const route = useRoute()
  const router = useRouter()
  let searchFieldRef = ref(null)

  const searchField = ref(store.query)
  const searchQuery = ref(store.query) // when user press 'Enter'
  const selectedMode = ref('primary')
  const emit = defineEmits(['switch-candidate'])

  const emitSearch = () => {
    searchQuery.value = searchField.value
    store.search(searchQuery.value, selectedMode.value)
      .then(router.push)
  }

  const searchLater = debounce(function () {
    // TODO: Prevent request while composing japanese text using IME
    // Otherwise, same (unchanged) request will be sent after each key press
    emitSearch()
  }, 250)

  const clearInputField = () => {
    searchFieldRef.value.focus()
    searchFieldRef.value.select()
  }

  const switchDictionary = () => {
    const modes = store.searchModes.map((i) => i.id)
    const idx = modes.findIndex((i) => i === selectedMode.value)
    selectedMode.value = modes[(idx + 1) % modes.length]
  }

  const shortkey = (event) => {
    if (event.srcKey === 'nextCandidate') {
      emit('switch-candidate', 'next')
    } else if (event.srcKey === 'prevCandidate') {
      emit('switch-candidate', 'prev')
    } else if (event.srcKey === 'focus') {
      this.clearInputField()
    }
  }

  onMounted(() => {
    searchField.value = route.params.query
    searchQuery.value = route.params.query
    selectedMode.value = store.current.mode || 'primary'
  })
</script>

<style lang="scss" scoped>
.search-field {
  border-bottom: 1px solid var(--border-color);

  .input-wrapper {
    margin: 2px 0;
    position: relative;
  }

  input[type='text'] {
    background: none;
    border: none;
    padding: 0.2em 0.6em 0.2em 0.6em;
    box-sizing: border-box;
    width: 100%;
  }

  .clear-button {
    position: absolute;
    right: 0.2em;
    bottom: 2px;
    cursor: pointer;
    font-size: clamp(16px, 1em, 1em);
    line-height: 0.8em;
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
</style>
