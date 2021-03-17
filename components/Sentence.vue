<template>
  <span class="vue-sentence">
    <template v-if="sentence">
      <span
        v-for="(line, lineIdx) of sentence"
        :key="`l${lineIdx}`"
        class="gloss-line"
      >
        <span v-for="(word, wordIdx) of line" :key="`w${wordIdx}`"
          ><a
            v-if="word.seq"
            :href="path(word.base, word.seq)"
            @click.prevent="search(word.base, word.seq)"
            >{{ word.text }}</a
          ><template v-else>{{ word.text }}</template></span
        >
      </span>
    </template>

    <template v-else>
      <span
        v-for="(line, lineIdx) of plainText"
        :key="`l${lineIdx}`"
        class="gloss-line"
        >{{ line }}</span
      >
    </template>
  </span>
</template>

<script>
export default {
  props: {
    plainText: { type: Array, required: true },
    seq: { type: Number, required: true },
  },
  async fetch() {
    const resp = await this.$axios.get(`/api/mecab/word/${this.seq}`)
    this.sentence = resp.data[0].gloss
  },
  data() {
    return {
      sentence: null,
    }
  },
  methods: {
    path(query, seq) {
      return this.$router.resolve({
        name: 'sub-search',
        params: { query, seq },
      }).href
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
