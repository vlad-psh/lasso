<template>
  <div class="image-view">
    <img :src="imgSrc" />
  </div>
</template>

<script>
export default {
  props: {
    payload: { type: Object, required: true },
  },
  computed: {
    imgSrc() {
      const i = this.payload
      if (!i) return null
      const page = '0000'.slice(i.page.toString().length) + i.page
      return `/jiten/data/${i.mode}/${page}.png`
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
