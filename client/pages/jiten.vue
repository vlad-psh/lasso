<template>
  <div id="jiten-app">
    <JitenNavigation :key="route.params.mode" />
    <JitenImage />
  </div>
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

<style lang="scss" scoped>
</style>
