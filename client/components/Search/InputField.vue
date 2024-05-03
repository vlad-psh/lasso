<template>
  <div
    class="search-component"
    @keydown.tab.prevent="() => switchSearchMode(1)"
    @keydown.shift.tab.prevent="() => switchSearchMode(-1)"
  >
    <div
      v-for="(mode, idx) in SEARCH_MODES"
      :key="mode.id"
      class="search-mode"
      :class="selectedMode === mode.id ? 'enabled' : 'disabled'"
    >
      <div
        class="mode-item"
        :class="mode.id"
        @click="() => setSearchMode(idx)"
        v-shortkey="['meta', idx + 1]"
        @shortkey="() => setSearchMode(idx)"
      >
        <component :is="mode.svg" />
      </div>

      <input
        class="shortkey-enabled"
        ref="inputFieldRefs"
        v-model="inputValues[mode.id]"
        v-shortkey="{
          focus: ['esc'],
          nextCandidate: ['arrowdown'],
          prevCandidate: ['arrowup'],
        }"
        type="text"
        placeholder="Search..."
        @shortkey="shortkey"
        @keydown.enter="emitSearch"
        @focus="() => setSearchMode(idx)"
      />
      <div class="clear-button" @click="clearInputField">
        <ClearIcon />
      </div>
    </div>

    <JitenNavigation v-if="route.name === 'jiten'" :key="route.params.mode"/>
  </div>
</template>

<script setup lang="ts">
  import { reactive, computed } from 'vue'
  import debounce from '@/js/debouncer.js'
  import ClearIcon from '../../assets/icons/clear.svg'
  import DictPrimaryLabel from '../../assets/icons/dict-primary.svg'
  import DictKokugoLabel from '../../assets/icons/dict-kokugo.svg'
  import DictKanjiLabel from '../../assets/icons/dict-kanji.svg'
  import DictOnomatLabel from '../../assets/icons/dict-onomat.svg'
  import { storeToRefs } from 'pinia';

  const store = useSearch()
  const route = useRoute()
  const router = useRouter()
  const { results, current: currentRef } = storeToRefs(store)

  const SEARCH_MODES = [
    { id: 'primary', title: '検索', svg: DictPrimaryLabel },
    { id: 'kokugo', title: '国語', svg: DictKokugoLabel },
    { id: 'kanji', title: '漢字', svg: DictKanjiLabel },
    { id: 'onomat', title: 'ｵﾉﾏﾄ', svg: DictOnomatLabel },
  ]

  const inputFieldRefs = ref([])
  const inputValues = reactive({
    primary: '',
    kokugo: '',
    kanji: '',
    onomat: '',
  })
  const selectedMode = ref('primary')

  // When search is performed by an outside component (eg. click on
  // mecab-parsed word node)
  watch(currentRef, () => {
    selectedMode.value = currentRef.value.mode
    inputValues[currentRef.value.mode] = currentRef.value.query
  })

  const emitSearch = () => {
    const query = inputValues[selectedMode.value]
    if (!query) return

    store.search(query, selectedMode.value)
      .then(router.push)
  }

  /* const searchLater = debounce(function () {
    // TODO: Prevent request while composing japanese text using IME
    // Otherwise, same (unchanged) request will be sent after each key press
    emitSearch()
  }, 250) */

  const setSearchMode = (idx: number) => {
    selectedMode.value = SEARCH_MODES[idx].id
    emitSearch()
    inputFieldRefs.value[idx].focus()
  }

  const selectedModeIdx = computed(() => SEARCH_MODES.findIndex(i => i.id == selectedMode.value))
  const modesCount = SEARCH_MODES.length

  const switchSearchMode = (incr: number) => {
    // Extra 'modesCount' is added to handle negative values of 'incr' well
    const newIdx = (selectedModeIdx.value + incr + modesCount) % modesCount
    setSearchMode(newIdx)
  }

  const clearInputField = () => {
    const currentInputField = inputFieldRefs.value[selectedModeIdx.value]
    currentInputField.focus()
    currentInputField.select()
  }

  const shortkey = (event) => {
    if (event.srcKey === 'nextCandidate' && selectedMode.value === 'primary') {
      shiftCandidate('next')
    } else if (event.srcKey === 'prevCandidate' && selectedMode.value === 'primary') {
      shiftCandidate('prev')
    } else if (event.srcKey === 'focus') {
      clearInputField()
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
    selectedMode.value = store.current.mode || 'primary'
    inputValues[selectedMode.value] = route.params.query
  })
</script>

<style lang="scss" scoped>
.search-component {
  height: var(--menu-height);
  display: flex;
  justify-content: stretch;
  align-items: stretch;

  .search-mode {
    position: relative;
    display: flex;
    align-items: stretch;

    &.disabled {
      .mode-item {
        svg {
          height: 35px;
        }
      }

      input {
        width: 0 !important;
        padding-left: 0;
        padding-right: 0;
      }

      .clear-button {
        display: none;
      }
    }

    &.enabled {
      background: #7771;
      color: #eee;

      svg {
        border-radius: 3px;
        height: 28px;
        width: 18px;
      }
    }

    .mode-item {
      background: inherit;
      display: flex;
      align-items: center;
      justify-content: center;
      width: 26px;
      height: var(--menu-height);
      cursor: pointer;

      &:hover {
        filter: saturate(0.8) brightness(0.8);
      }

      svg {
        transition: width 0.1s, height 0.1s;
        color: var(--color);
        background: var(--background);
      }

      &.primary {
        --background: #6c05a5;
        --color: white;
      }
      &.kokugo {
        --background: #f5203e;
        --color: white;
      }
      &.kanji {
        --background: #66a48e;
        --color: white;
      }
      &.onomat {
        --background: #fce35a;
        --color: #665616;
      }
    }
  }

  input[type='text'] {
    border: none;
    padding: 0.2em 0.6em 0.2em 0.2em;
    box-sizing: border-box;
    background: inherit;
    color: inherit;
    border-radius: 0 !important; // iOS has rounded corners by default
    width: 15em;
    transition: width 0.2s ease-in-out, padding 0.2s;

    &:active,
    &:focus {
      outline-width: 0;
      outline: none;
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

@media (max-width: 568px) {
  .search-component {
    flex-direction: row-reverse;

    .search-mode input {
      width: 7em;
    }
  }
}
</style>
