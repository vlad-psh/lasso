<template>
  <div class="image-view">
    <img :src="imgSrc" />
  </div>
</template>

<script>
export default {
  computed: {
    imgSrc() {
      const { mode, page } = this.$store.state.search.current

      if (mode === 'primary' || !page) return null

      const pageStr = '0000'.slice(page.toString().length) + page
      return `/jiten/data/${mode}/${pageStr}.png`
    },
  },
}
</script>

<style lang="scss">
.image-view {
  img {
    width: 100%;
  }
}
</style>
