<template>
  <div id="search-app">
    <div class="browse-panel">
      <SearchInputField
        @switch-candidate="(direction) => switchCandidate(direction)"
      />

      <div class="search-results">
        <SearchCandidateItem
          v-for="(item, itemIndex) in results"
          :key="`candidate-${itemIndex}`"
          ref="candidates"
          :item="item"
          :is-selected="item[0] === currentRef.seq"
          :on-click="() => store.selectSeq(item[0])"
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

  const switchCandidate = (direction) => {
    let idx = results.findIndex((i) => i[0] === currentSearch.seq)

    if (direction === 'prev' && idx > 0) idx--
    else if (direction === 'next' && idx + 1 < results.length) idx++

    store.selectSeq(results[idx][0])
    scrollToIndex(idx)
  }

  onMounted(() => {
    cache.loadDrills(true)
  })
</script>

<style lang="scss" scoped>
#search-app {
  display: grid;
  grid-template-columns: clamp(10em, 25vw, 22em) 1fr;
  grid-template-rows: 100%;
  overflow: hidden;

  .browse-panel {
    border: 0px solid var(--border-color);
    border-right-width: 1px;
    height: 100%;
    display: grid;
    grid-template-rows: auto auto 1fr;

    .search-results {
      height: 100%;
      overflow-y: auto;
      overflow-x: hidden;
    }
  }

  .contents-panel {
    height: 100%;
    overflow-y: auto;
  }
}

@media (max-width: 568px) {
  #search-app {
    grid-template-columns: 1fr 10em;

    .browse-panel {
      grid-row: 1;
      grid-column: 2;
      border-right-width: 0;
      border-left-width: 1px;
    }
    .contents-panel {
      grid-row: 1;
      grid-column: 1;
      font-size: 1em;
    }
  }
}
</style>
