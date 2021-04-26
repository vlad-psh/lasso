<template>
  <div class="vue-word word-card" :data-seq="seq">
    <WordLoading v-if="!word" />

    <div v-if="word" class="word-info">
      <WordKrebs :krebs="word.krebs" :seq="seq" />
      <PitchWordNhk :payload="word.nhk_data" />

      <WordGloss
        v-if="word.meikyo"
        :payload="word.meikyo"
        :seq="seq"
        lang="jp"
      />
      <WordGloss v-if="word.en" :payload="word.en || []" lang="uk" />
      <WordGloss v-if="word.ru" :payload="word.ru || []" lang="ru" />
      <WordGloss v-if="word.az" :payload="word.az || []" lang="az" />

      <EditableText
        :text-data="word.comment"
        placeholder="Add comment..."
        @save="saveComment"
      ></EditableText>

      <WordCards :cards="word.cards || []" />
    </div>

    <div class="kanji-info">
      <div class="kanji-list">
        <Kanji v-for="k of kanji" :key="'kanji' + k.id" :payload="k" />
      </div>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    seq: { type: Number, required: true },
  },
  async fetch() {
    this.word = await this.$store.dispatch('cache/loadWord', this.seq)
  },
  data() {
    return { word: null }
  },
  computed: {
    kanji() {
      return (this.word ? this.word.kanji || '' : '')
        .split('')
        .map((k) => this.$store.state.cache.kanji[k])
    },
  },
  methods: {
    saveComment(text, cb) {
      this.$axios
        .post(`/api/word/${this.seq}/comment`, { comment: text })
        .then((resp) => {
          this.$store.commit('cache/UPDATE_WORD_COMMENT', {
            seq: this.seq,
            text,
          })
          cb.resolve()
        })
        .catch((e) => {
          cb.reject(e.message)
        })
    },
  },
}
</script>

<style lang="scss">
// TODO: fix 'non-selectable'
.word-card {
  padding: 0.6em 0;
  display: grid;
  grid-template-columns: 3fr 2fr;

  .word-info,
  .kanji-info {
    margin: 0 0.5em;
  }

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
    max-width: 25em;
    display: inline-block;
    vertical-align: top;
    margin-bottom: 1em;

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

@media (max-width: 568px) {
  body {
    .word-card {
      display: block;

      .kanji-list {
        margin-top: 1em;
        .vue-kanji {
          max-width: unset;
        }
      }
    }
  }
}
</style>
