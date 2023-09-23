<template>
  <div class="image-view">
    <img :src="imgSrc" />
  </div>
</template>

<script setup>
  const search = useSearch()

  const imgSrc = computed(() => {
    const { mode, page } = search.current

    if (mode === 'primary' || !page) return null

    const pageStr = '0000'.slice(page.toString().length) + page
    return `/jiten/data/${mode}/${pageStr}.png`
  })
</script>

<style lang="scss">
.image-view {
  img {
    width: 100%;
  }
}
</style>
