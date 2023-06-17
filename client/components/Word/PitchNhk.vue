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

<script setup>
  import NHKIcon from '../../assets/icons/nhk.svg'

  const props = defineProps({
    payload: { type: Object, default: null },
  })

  const words = computed(() => {
    const words = []
    for (const w of Object.keys(props.payload)) {
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
  })
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
