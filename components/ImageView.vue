<template>
  <div class="image-view">
    <img :src="imgSrc" />
  </div>
</template>

<script>
export default {
  computed: {
    imgSrc() {
      const current = this.$search.current
      if (!current) return null
      const page = '0000'.slice(current.page.toString().length) + current.page
      return `/jiten/data/${current.book}/${page}.png`
    },
  },
}
</script>
