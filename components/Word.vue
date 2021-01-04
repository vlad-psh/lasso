<template>
  <div class="vue-word word-card" :data-seq="seq">
    <WordKrebs :krebs="word.krebs" />

    <WordGloss :glosses="word.en || []" flag="🇬🇧" />
    <WordGloss :glosses="word.ru || []" flag="🇷🇺" />

    <PitchWordNhk :payload="word.nhk_data" />

    <WordCards :cards="word.cards || []" />

    <!-- vue editable text -->
    <!-- kanji list -->
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
  },
}
</script>

<style lang="scss">
// TODO: fix 'non-selectable'
.word-card {
  padding: 0.6em 0;

  .expandable-list {
    display: inline-block;
    vertical-align: middle;

    &.word-krebs {
      padding-bottom: 7px;

      .expandable-list-item {
        margin: 0 0.6em 0 -0.3em;
        border-bottom: none;
        color: inherit;
      }
    }
    .expandable-list-item {
      display: inline-block;
      text-align: center;
      vertical-align: middle;
      margin: 0 0.4em;
      cursor: pointer;
      border-bottom: 1px dashed #008ace;
      color: #008ace;

      &:hover {
        color: #c00;
        border-bottom-color: #c00;
      }
      .word-kreb {
        font-size: 1.4em;
        position: relative;
        display: inline-block;
        cursor: pointer;
        border: none;
        padding: 0 0.3em 0.2em 0.3em; // bottom padding needed so that bottom border will not intersects with pitch accent
        /* transparent border; so that height is equal with common words with visible border*/
        border-bottom: 2px solid rgba(255, 255, 255, 0);

        &.common {
          border-bottom-color: green;
          border-bottom-style: dotted;
        }
      } /* end of .word-kreb */

      .jisho-search-link {
        // @include non-selectable;
        display: inline-block;
        text-decoration: none;
        font-size: 0.9em;
        &:hover {
          opacity: 0.6;
        }
      }

      .expandable-list-arrow {
        display: inline-block;
        position: absolute;
        padding: 0;

        box-sizing: border-box;
        height: 5px;
        width: 5px;
        margin: 2px 0 0 -5px;
        content: ' ';
        border: 5px solid transparent;
        // border-bottom-color: var(--expander-bg);
      }

      .level {
        // @include non-selectable;
        display: inline-block;
        background-color: #ffbc11;
        color: #99700a;
        border-radius: 2em;
        font-size: 0.6em;
        line-height: 1.6em;
        width: 1.6em;
        height: 1.6em;
        text-align: center;
        vertical-align: middle;
      }
    } /* end of .expandable-list-item */
  } /* end of .expandable-list */

  .expandable-list-container {
    background: var(--expander-bg);
    color: var(--expander-color);
    padding: 0.5em 0;
    margin-top: 5px;
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
}
</style>
