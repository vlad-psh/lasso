<template>
  <div class="word-component">
    <div class="word-card" :data-seq="seq">
      <WordLoading v-if="!word || word.seq !== seq" />

      <div v-if="word" class="word-info">
        <WordKrebs :krebs="word.krebs" :seq="seq" />
        <WordDrills :word="word" />
        <WordPitchNhk :payload="word.nhk_data" />

        <WordGloss v-if="word.meikyo" :payload="word.meikyo" lang="jp" />
        <WordGloss v-if="word.en" :payload="word.en || []" lang="uk" />
        <WordGloss v-if="word.ru" :payload="word.ru || []" lang="ru" />
        <WordGloss v-if="word.az" :payload="word.az || []" lang="az" />

        <EditableText
          :text-data="word.comment"
          placeholder="Add comment..."
          @save="saveComment"
        />

        <WordWK :cards="word.cards || []" />
      </div>
    </div>

    <div class="word-kanji">
      <KanjiComponent v-for="k of kanji" :key="'kanji' + k.id" :payload="k" />
    </div>
  </div>
</template>

<script setup>
  import { storeToRefs } from 'pinia'

  const props = defineProps({
    seq: { type: Number, required: true },
  })

  const cache = useCache()
  const word = ref()
  const kanji = ref([])
  const { kanji: cachedKanji } = storeToRefs(cache)

  const loadWord = async (seq) => {
    word.value = await cache.loadWord(seq)
    kanji.value = word.value.kanji.split('')
      .map((k) => cachedKanji.value[k])
  }

  watch(() => props.seq, loadWord)
  loadWord(props.seq)

  const saveComment = async (text, cb) => {
    try {
      await $fetch(`/api/word/${props.seq}/comment`, {
        method: 'POST',
        body: { comment: text }
      })

      cache.updateWordComment({ seq: props.seq, text })
      cb.resolve()
    } catch (e) {
      console.error('Request failed:', e)
      cb.reject(e.message)
    }
  }
</script>

<style lang="scss" scoped>
// TODO: fix 'non-selectable'
.word-component {
  display: grid;
  grid-template-columns: 3fr 2fr;
  grid-column-gap: 0.6em;

  .word-card {
    padding: 0.6em;
  }

  .word-kanji {
    border-left: 1px solid var(--border-color);
    max-width: 25em;
    display: inline-block;
    vertical-align: top;

    .vue-editable-text {
      margin: 0 -0.6em;
      font-size: 0.9em;
    }
  }
} /* end of .word-component */

@media (max-width: 568px) {
  body {
    .word-component {
      display: block;

      .word-kanji {
        border-left: none;
        margin-top: 1em;
        max-width: unset;
      }
    }
  }
}
</style>
