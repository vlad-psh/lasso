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
    route.query.query,
    route.query.mode,
    {
      seq: Number.parseInt(route.query.seq),
    }
  )
</script>
