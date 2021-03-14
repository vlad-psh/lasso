<template>
  <span class="vue-sentence">
    <span v-for="(word, idx) of payload" :key="`w${idx}`"
      ><NuxtLink
        v-if="word.seq"
        :to="path(word.base, word.seq)"
        @click.native="search(word.base, word.seq)"
        >{{ word.text }}</NuxtLink
      ><template v-else>{{ word.text }}</template></span
    >
  </span>
</template>

<script>
export default {
  props: {
    payload: { type: Array, required: true },
  },
  methods: {
    path(query, seq) {
      return { name: 'sub-search', params: { query, seq } }
    },
    search(query, seq) {
      this.$search.execute({ query, seq, mode: 'primary', popRoute: true })
    },
  },
}
</script>

<style lang="scss">
.vue-sentence {
  a {
    text-decoration: none;
    color: var(--color);
    background: var(--bg-secondary);
  }
}
</style>
