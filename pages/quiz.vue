<template>
  <div
    id="sentence-quiz-app"
    v-shortkey="{
      correct: ['y'],
      incorrect: ['n'],
      esc: ['esc'],
      space: ['space'],
    }"
    class="study-card"
    @shortkey="shortkey"
  >
    <div class="sentence-question">
      <div class="center-block">
        <div
          v-for="(word, wordIndex) of segments"
          :key="wordIndex"
          class="sentence-word-container"
        >
          <div v-if="word.seq">
            <div class="sentence-word-tooltip" :class="word.answer">
              <span v-if="word.index" class="word-index">{{ word.index }}</span>
              {{ word.answer || (word.highlight ? '\u2b50' : '') }}
            </div>
            <div
              v-shortkey="[word.index]"
              class="sentence-word word-question"
              :class="{ answered: !!word.answer }"
              @click="selectWord(wordIndex)"
              @shortkey="selectWord(wordIndex)"
            >
              {{ word.text }}
            </div>
          </div>
          <div v-else class="sentence-word">{{ word.text }}</div>
        </div>
      </div>
      <div class="action-buttons">
        <SentenceAudio
          v-if="sentence.id"
          :id="sentence.id"
          :key="sentence.id"
        />
      </div>
    </div>

    <div v-if="selectedWord">
      <div v-if="selectedSegment.answer" class="answer-buttons">
        <div class="answer-button yellow" @click="resetAnswer">
          Answered: {{ selectedSegment.answer }}; RESET
        </div>
      </div>
      <div v-else class="answer-buttons">
        <div class="answer-button red" @click="setAnswer('incorrect')">
          NO
          <div class="answer-details">
            + 3 + {{ selectedKreb.progress.incorrect }}
          </div>
        </div>
        <div class="answer-button green" @click="setAnswer('correct')">
          YES
          <div class="answer-details">
            + {{ selectedKreb.progress.correct }}'
          </div>
        </div>
      </div>

      <Word :seq="selectedWord.seq" :word-data="selectedWord" />
    </div>

    <div v-if="allAnswered && !selectedWord">
      <div v-if="allAnswered" class="answer-buttons">
        <div class="answer-button blue" @click="submit">SUBMIT</div>
      </div>
      <div v-if="sentence.english" class="center-block" style="margin-top: 1em">
        Translation: {{ sentence.english }}
      </div>
    </div>
  </div>
</template>

<script>
export default {
  async fetch() {
    const { store, route } = this.$nuxt.context
    const resp = await this.$axios.get('/api/question', {
      params: {
        drill_id: route.query.drill_id,
        type: route.query.type,
      },
    })

    for (const word of resp.data.payload.words)
      store.commit('cache/PUSH_WORD', word)
    for (const kanji of resp.data.payload.kanjis)
      store.commit('cache/ADD_KANJI', kanji)

    let componentIndex = 1
    for (const segment of resp.data.structure)
      if (segment.seq) {
        segment.answer = null
        segment.index = componentIndex++
      }

    this.sentence = resp.data
  },
  data() {
    return { sentence: {}, selectedIndex: null, loading: false }
  },
  computed: {
    segments() {
      return this.sentence.structure || []
    },
    selectedSegment() {
      return this.selectedIndex !== null
        ? this.segments[this.selectedIndex]
        : null
    },
    selectedWord() {
      return this.selectedSegment
        ? this.sentence.payload.words.find(
            (i) => i.seq === this.selectedSegment.seq
          )
        : null
    },
    selectedKreb() {
      return this.selectedWord
        ? this.selectedWord.krebs.find(
            (i) => i.title === this.selectedSegment.base
          )
        : null
    },
    allAnswered() {
      const mainWord = this.segments.find((i) => i.highlight === true)
      if (mainWord !== undefined) {
        return mainWord.answer !== null
      } else {
        const unanswered = this.segments.filter((i) => i.seq && !i.answer)
        return !!(unanswered.length === 0 && this.segments.length !== 0)
      }
    },
  },
  methods: {
    shortkey(event) {
      if (this.selectedSegment) {
        if (event.srcKey === 'correct' || event.srcKey === 'incorrect') {
          this.setAnswer(event.srcKey)
        } else if (event.srcKey === 'esc') this.selectedIndex = null
      }
      if (event.srcKey === 'space') {
        this.allAnswered ? this.submit() : this.selectHighlighted()
      }
    },
    selectWord(sentenceIndex) {
      this.selectedIndex =
        this.selectedWord &&
        this.selectedWord.seq === this.segments[sentenceIndex].seq
          ? null
          : sentenceIndex
    },
    selectHighlighted() {
      const i = this.segments.findIndex((s) => s.highlight === true)
      this.selectWord(i !== -1 ? i : 0) // select highlighted or first
    },
    setAnswer(answerText) {
      this.selectedSegment.answer = answerText
      this.selectedIndex = null
    },
    resetAnswer() {
      this.selectedSegment.answer = null
    },
    async submit() {
      this.loading = true
      const answers = this.segments
        .filter((i) => i.seq)
        .map(function (i) {
          return { seq: i.seq, base: i.base, answer: i.answer }
        })

      try {
        await this.$axios.post('/api/quiz', {
          drill_id: this.$route.query.drill_id,
          type: this.$route.query.type,
          sentence_id: this.sentence.id,
          answers,
        })

        this.$fetch()
      } catch (e) {
        alert(e)
      }
    },
  },
}
</script>

<style lang="scss">
#sentence-quiz-app {
  margin: 0;

  .sentence-question {
    background-color: #ffec83;
    text-align: center;
    position: relative;
    max-height: 12em;
    display: grid;
    grid-template-columns: 1fr auto;
    grid-template-rows: 1fr;

    .action-buttons {
      display: flex;
      flex-direction: column;
      justify-content: center;

      & > * {
        margin: 0.3em;
      }
    }
    .center-block {
      padding: 1.5em 0 2.2em 0;
      overflow-y: auto;
    }

    .sentence-word-container {
      display: inline-block;
      vertical-align: bottom;

      .sentence-word {
        font-size: 3em;
        margin: 0 1px;
      }
      .sentence-word-tooltip {
        font-size: 8pt;
        border-bottom: 2px solid rgba(255, 255, 255, 0);
        margin: 0 2px;
        color: #878764;

        .word-index {
          padding: 0 0.2em;
          margin: 0.2em;
          display: inline-block;
          font-size: 0.9em;
          border-radius: 0.2em;
          color: #0007;
          background: #fff7;
          box-shadow: 1px 1px 0 #7777;
        }

        &.correct {
          border-bottom: 2px solid #4caf50;
        }
        &.incorrect {
          border-bottom: 2px solid #e51c23;
        }
        &.soso {
          border-bottom: 2px solid #2196f3;
        }
        &.burned {
          border-bottom: 2px solid #ff9800;
        }
      }
    }

    .word-question {
      background: white;
      cursor: pointer;

      &.answered {
        background: #fcefa9;
      }
    }

    .word-question:hover,
    .word-question-answered:hover {
      color: #c00;
      border-bottom: 2px solid #c00;
      margin-bottom: -2px;
    }
  } /* end of .sentence-question */

  .answer-buttons {
    display: grid;
    grid-gap: 3px;
    margin-top: 3px;
    grid-auto-columns: auto;

    .answer-button {
      padding: 0.5em 1em;
      cursor: pointer;
      text-align: center;
      min-height: 2em;
      grid-column: auto;
      grid-row: 1;

      .answer-details {
        font-size: x-small;
        margin: -0.3em 0 -0.2em 0;
        opacity: 0.6;
      }
    }
  } /* end of .answer-buttons */
} /* end of #sentence-quiz-app */

html[class='dark-mode'] body {
  #sentence-quiz-app {
    .sentence-question {
      background: none;
      color: var(--color-secondary);
      border-bottom: 2px dotted var(--bg-secondary);
      .sentence-word-container {
        .word-question {
          background-color: rgba(255, 255, 255, 0.1);
        }
        .word-question-answered {
          background-color: transparent;
        }
        .sentence-word-tooltip {
          color: inherit;
        }
      }
    }
  }
}
</style>
