<template>
  <div class="vue-word">
    {{ $store.state.cache.words[seq] }}
    <div class="tear-line" />
  </div>
</template>

<script>
export default {
  props: {
    seq: { type: Number, required: true },
  },
  data() {
    return {}
  },
}
</script>

<style lang="scss">
.vue-word {
  &.highlighted {
    animation: 2s ease-out 0s 1 normal blink-highlight;
  }
}
.tear-line {
  width: 100%;
  height: 16px;
  background-repeat: repeat-x;
  background-size: 10px 16px;
}
</style>
