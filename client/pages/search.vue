<template>
  <div id="search-app">
    <div class="browse-panel">
      <SearchInputField
        @switch-candidate="(direction) => shiftCandidate(direction)"
      />

      <div class="search-results">
        <SearchCandidateItem
          v-for="(item, itemIndex) in results"
          :key="`candidate-${itemIndex}`"
          ref="candidates"
          :item="item"
          :is-selected="item[0] === currentRef.seq"
          :on-click="() => openCandidate(item[0])"
        />
      </div>
    </div>
    <div class="contents-panel">
      <WordComponent
        v-if="currentMode === 'primary'"
        :seq="currentRef.seq"
      />
      <JitenImage v-else-if="currentMode === 'jiten'" />
    </div>
  </div>
</template>

<script setup>
  import { storeToRefs } from 'pinia';

  const store = useSearch()
  const cache = useCache()
  const router = useRouter()
  const { current: currentRef } = storeToRefs(store)
  const { results } = storeToRefs(store)
  let candidates = ref(null)

  const currentMode = computed(() => {
    if (!currentRef.value.mode) return null
    return currentRef.value.mode === 'primary' ? 'primary' : 'jiten'
  })

  const scrollToIndex = (idx) => {
    if (!(candidates && candidates[idx])) return

    candidates[idx].$el.scrollIntoView({
      behavior: 'smooth',
      block: 'nearest',
      inline: 'nearest',
    })
  }

  const openCandidate = (seq, idx) => {
    store.selectSeq(seq)
    router.replace({
      name: router.currentRoute.value.name,
      params: { ...router.currentRoute.value.params, seq },
    })
    scrollToIndex(idx)
  }

  const shiftCandidate = (direction) => {
    let idx = results.value.findIndex((i) => i[0] === currentRef.value.seq)

    if (direction === 'prev' && idx > 0) idx--
    else if (direction === 'next' && idx + 1 < results.value.length) idx++

    openCandidate(results.value[idx][0], idx)
  }

  onMounted(() => {
    // TODO: Keepalive search page
    cache.loadDrills(true)
  })
</script>

<style lang="scss" scoped>
#search-app {
  --search-results-width: clamp(10em, 25vw, 22em);

  .browse-panel {
    position: fixed;
    z-index: 150; // on top of "main menu" (which has z-index = 100)
    top: 0;
    left: 0;
    height: 100%;
    width: var(--search-results-width);
    border: 0px solid var(--border-color);
    border-right-width: 1px;
    display: grid;
    grid-template-rows: auto auto 1fr;

    .search-results {
      height: 100%;
      overflow-y: auto;
      overflow-x: hidden;
    }
  }

  .contents-panel {
    margin-left: var(--search-results-width);
  }
}

@media (max-width: 568px) {
  #search-app {
    .browse-panel {
      left: unset;
      right: 0;
      border-right-width: 0;
      border-left-width: 1px;
    }
    .contents-panel {
      margin-left: unset;
      margin-right: var(--search-results-width);
      font-size: 1em;
    }
  }
}
</style>
