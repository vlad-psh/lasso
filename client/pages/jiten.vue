<template>
  <JitenImage />
</template>

<script setup>
  const route = useRoute()
  const store = useSearch()

  definePageMeta({
    key: route => route.name,
    keepalive: true,
  })

  store.search(
    route.params.query,
    route.params.mode,
    {
      seq: Number.parseInt(route.params.seq),
    }
  )
</script>
