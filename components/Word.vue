<template>
  <div class="vue-word word-card" :data-seq="seq">
    <WordKrebs :krebs="word.krebs" />

    <WordGloss :glosses="word.en || []" flag="🇬🇧" />
    <WordGloss :glosses="word.ru || []" flag="🇷🇺" />

    <PitchWordNhk :payload="word.nhk_data" />

    <WordCards :cards="word.cards || []" />

    <!-- vue editable text -->
    <div class="tear-line" />
    <div class="kanji-list">
      <Kanji v-for="k of kanji" :key="'kanji' + k.id" :payload="k" />
    </div>
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
  computed: {
    word() {
      return this.$store.state.cache.words[this.seq]
    },
    kanji() {
      return (this.word.kanji || '')
        .split('')
        .map((k) => this.$store.state.cache.kanji[k])
    },
  },
}
</script>

<style lang="scss">
// TODO: fix 'non-selectable'
.word-card {
  padding: 0.6em 0;

  .word-details {
    text-align: justify;
    padding: 0.3em;
    line-height: 1.6em;

    .icon {
      // @include non-selectable;
      display: inline-block;
      font-size: 1.4em;
      vertical-align: middle;
      margin-right: 0.3em;
      line-height: 0;
    }
    .pos {
      color: green;
      font-style: italic;
      font-size: 0.9em;
    }
  } /* end of .word-glosses */

  .action-buttons {
    opacity: 0.4;
    font-size: 0.8em;

    &:hover {
      opacity: 1;
    }
    a {
      cursor: pointer;
    }
  }

  .word-comment-form.vue-editable-text {
    padding: 0.1em 0.6em;
    margin: -0.1em auto;

    &:hover {
      background-color: rgba(128, 128, 128, 0.2);
      cursor: pointer;
    }
    p {
      margin: 0.4em 0;
      text-align: justify;
    }
    textarea {
      width: 100%;
      height: 8em;
      resize: vertical;
    }
  } /* end of .word-comment-form */

  .vue-kanji {
    width: calc(50% - 0.5em);
    display: inline-block;
    vertical-align: top;
    margin-top: 1em;
    &:nth-child(odd) {
      margin-right: 0.5em;
    }
    .vue-editable-text {
      margin: 0 -0.6em;
      font-size: 0.9em;
    }
  }
} /* end of .word-card */

.tear-line {
  width: 100%;
  height: 16px;
  background-repeat: repeat-x;
  background-size: 10px 16px;
  background-image: url('~assets/backgrounds/tear-line.svg');
  margin-top: 1em;
}
</style>
