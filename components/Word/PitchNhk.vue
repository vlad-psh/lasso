<template>
  <div v-if="payload" class="word-details center-block">
    <div class="icon-nhk"><NHKIcon /></div>
    <span class="vue-pitch-word">
      <span v-for="(word, wordIdx) of words" :key="wordIdx" class="word">
        <span
          v-for="(char, charIdx) of word"
          :key="charIdx"
          :class="char['cl']"
          >{{ char['ch'] }}</span
        >
      </span>
    </span>
  </div>
</template>

<script>
import NHKIcon from '@/assets/icons/nhk.svg?inline'

export default {
  components: { NHKIcon },
  props: {
    payload: { type: Object, default: null },
  },
  computed: {
    words() {
      const words = []
      for (const w of Object.keys(this.payload)) {
        const word = []
        for (const c of w.split('')) {
          if (c === '@') {
            word[word.length - 1].cl.push('voiceless')
          } else if (c === '~') {
            word[word.length - 1].cl.push('nasal')
          } else if (c === '=') {
            word[word.length - 1].cl.push('t')
          } else if (c === '^') {
            word[word.length - 1].cl.push('tr')
          } else {
            word.push({ ch: c, cl: [] })
          }
        }
        words.push(word)
      }
      return words
    },
  },
}
</script>

<style lang="scss">
.icon-nhk {
  display: inline-block;
  padding: 0.4em;

  svg {
    width: 3em;
    height: 1em;
    vertical-align: sub;
  }
}
</style>
