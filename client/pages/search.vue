<template>
  <SplitPage>
    <template v-slot:list>
      <SearchCandidateItem
        v-for="(item, itemIndex) in results"
        :key="`candidate-${itemIndex}`"
        ref="candidates"
        :item="item"
        :is-selected="item[0] === currentRef.seq"
        :on-click="() => openCandidate(item[0])"
      />
    </template>
    <template v-slot:content>
      <WordComponent v-if="currentRef.seq" :seq="currentRef.seq" />
    </template>
  </SplitPage>
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

  // When another candidate item is selected
  watch(() => route.params.seq, (seqStr) => {
    const seq = Number.parseInt(seqStr)
    const idx = results.value.findIndex(i => i[0] === seq)
    store.selectSeq(seq)
    scrollToIndex(idx)
  })

  // When clicked on mecab-parsed word node (both query and seq will be changed)
  // When going back/forward browser's history
  watch(() => route.params.query, (query) => {
    const seq = Number.parseInt(route.params.seq)
    store.search(query, 'primary', { seq })
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
    router.replace({
      name: 'search',
      params: { query: route.params.query, seq },
    })
  }
</script>
