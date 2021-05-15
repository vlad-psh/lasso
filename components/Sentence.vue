<template>
  <span class="vue-sentence">
    <span
      v-for="(line, lineIdx) of payload"
      :key="`l${lineIdx}`"
      class="gloss-line"
    >
      <span v-for="(word, wordIdx) of line" :key="`w${wordIdx}`"
        ><a
          v-if="word.length == 3"
          :href="path(word[1], word[2])"
          @click.prevent="search(word[1], word[2])"
          >{{ word[0] }}</a
        ><template v-else>{{ word[0] }}</template></span
      >
    </span>
  </span>
</template>

<script>
export default {
  props: {
    payload: { type: Array, required: true },
  },
  methods: {
    path(reading, base) {
      return this.$router.resolve({
        name: 'sub-search',
        params: { query: `${reading}+${base}` },
      }).href
    },
    search(reading, base) {
      const query = `${reading}+${base}`
      this.$search.execute({ query, mode: 'primary', popRoute: true })
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
    margin: 0 -1px;
    border: 1px solid var(--bg);
  }

  .gloss-line + .gloss-line {
    &:before {
      content: '';
      display: block;
    }
  }
}
</style>
