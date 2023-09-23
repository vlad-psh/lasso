<template>
  <div id="search-app">
    <div class="browse-panel">
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
      <WordComponent :seq="currentRef.seq" />
    </div>
  </div>
</template>

<script setup>
  import { storeToRefs } from 'pinia';

  const store = useSearch()
  const cache = useCache()
  const router = useRouter()
  const route = useRoute()
  const { current: currentRef } = storeToRefs(store)
  const { results } = storeToRefs(store)
  let candidates = ref(null)

  definePageMeta({
    key: route => route.name,
    keepalive: true,
  })
  cache.loadDrills() // Will load drills lists only if NOT already loaded
  store.search(
    route.params.query,
    'primary',
    {
      seq: Number.parseInt(route.params.seq),
    }
  )

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

  /* const shiftCandidate = (direction) => {
    let idx = results.value.findIndex((i) => i[0] === currentRef.value.seq)

    if (direction === 'prev' && idx > 0) idx--
    else if (direction === 'next' && idx + 1 < results.value.length) idx++

    openCandidate(results.value[idx][0], idx)
  } */
</script>

<style lang="scss" scoped>
#search-app {
  .browse-panel {
    position: fixed;
    top: var(--menu-height);
    left: 0;
    height: calc(100% - var(--menu-height));
    width: var(--search-input-width);
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
    margin-left: var(--search-input-width);
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
      margin-right: var(--search-input-width);
      font-size: 1em;
    }
  }
}
</style>
