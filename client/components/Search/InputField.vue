<template>
  <div class="search-field">
    <SearchModeSelector
      :selected-mode="selectedMode"
      @change="(modeId) => (selectedMode = modeId)"
      @search="emitSearch"
    />
    <input
      class="shortkey-enabled"
      ref="searchFieldRef"
      v-model="searchField"
      v-shortkey="{
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
</template>

<script setup>
  import debounce from '@/js/debouncer.js'
  import ClearIcon from '../../assets/icons/clear.svg'
  import { storeToRefs } from 'pinia';

  const store = useSearch()
  const route = useRoute()
  const router = useRouter()
  let searchFieldRef = ref(null)
  const { results, current: currentRef } = storeToRefs(store)

  const searchField = ref(store.query)
  const searchQuery = ref(store.query) // when user press 'Enter'
  const selectedMode = ref('primary')

  const emitSearch = () => {
    searchQuery.value = searchField.value
    store.search(searchQuery.value, selectedMode.value)
      .then(router.push)
  }

  /* const searchLater = debounce(function () {
    // TODO: Prevent request while composing japanese text using IME
    // Otherwise, same (unchanged) request will be sent after each key press
    emitSearch()
  }, 250) */

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
      shiftCandidate('next')
    } else if (event.srcKey === 'prevCandidate') {
      shiftCandidate('prev')
    } else if (event.srcKey === 'focus') {
      this.clearInputField()
    }
  }

  const shiftCandidate = (direction) => {
    if (store.current.mode !== 'primary') return

    let idx = results.value.findIndex((i) => i[0] === currentRef.value.seq)

    if (direction === 'prev' && idx > 0) idx--
    else if (direction === 'next' && idx + 1 < results.value.length) idx++

    router.replace({
      name: 'search',
      params: {
        query: route.params.query,
        seq:   results.value[idx][0],
      },
    })
  }

  onMounted(() => {
    searchField.value = route.params.query
    searchQuery.value = route.params.query
    selectedMode.value = store.current.mode || 'primary'
  })
</script>

<style lang="scss" scoped>
.search-field {
  height: var(--menu-height);
  width: var(--search-input-width);
  display: flex;
  align-items: stretch;
  justify-content: stretch;
  position: relative;
  background: rgb(73, 74, 79, 0.35);

  input[type='text'] {
    background: none;
    border: none;
    padding: 0.2em 0.6em 0.2em 0.6em;
    box-sizing: border-box;
    color: white;
    flex-grow: 2;
    border-bottom: 1px solid transparent;
    border-radius: 0 !important; // iOS has rounded corners by default
    min-width: 0;

    &:active,
    &:focus {
      background: white;
      color: #222;
      outline-width: 0;
      outline: none;
      border-bottom: 1px solid var(--border-color);
    }
  }

  .clear-button {
    position: absolute;
    right: 0;
    top: 0;
    height: var(--menu-height);
    cursor: pointer;
    padding: 0 0.5em;
    display: flex;
    align-items: center;
    line-height: 0.9em;

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
