<template>
  <SplitPage>
    <template v-slot:list>
      <div class="title">{{data.drill.title}}</div>
      <div
        v-for="(item, itemIndex) in data.words"
        :class="{ selected: item.seq === currentRef.seq }"
        :key="`candidate-${itemIndex}`"
        ref="candidates"
        class="candidate-item"
        @click="() => openCandidate(item.seq)"
      >
        {{ item.title }}
      </div>
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
  const route = useRoute()
  const router = useRouter()
  const { current: currentRef } = storeToRefs(store)
  const { data } = await useAPI(`/api/drill/${route.params.id}`)

  const openCandidate = (seq, idx) => {
    router.replace({
      name: 'drills-id',
      params: { id: route.params.id },
      query: { seq },
    })
  }

  watch(() => route.query.seq, (seqStr) => {
    const seq = Number.parseInt(seqStr)
    store.updateCurrent({ mode: 'drill', query: undefined, seq })
  })
</script>

<style lang="scss" scoped>
:deep(.search-results) {
  display: flex;
  flex-wrap: wrap;
  justify-content: space-evenly;
}
:deep(.search-results .candidate-item) {
  padding: 0.4em 0.5em;
}
:deep(.search-results .candidate-item.selected) {
  padding: 0.4em 0.5em;
}
.title {
  width: 100%;
  text-align: center;
  background: linear-gradient(to bottom, #7770, #7777775e);
  font-size: 0.7em;
  font-weight: bold;
  text-shadow: 0 1px 0 white;
  padding: 0.3em 0 0.3em;
}
html[class~='dark-mode'] body {
  .title {
    color: #c5c4d0;
    text-shadow: 0 1px 0 #3c3c3c;
    background: linear-gradient(to top, rgba(119, 119, 119, 0), rgba(74, 107, 143, 0.37))
  }
}
</style>
