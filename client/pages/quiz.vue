<template>
  <div
    id="sentence-quiz-app"
    v-shortkey="{
      correct: ['y',],
      incorrect: ['k'],
      esc: ['esc'],
      space: ['space'],
      enter: ['enter'],
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
              class="sentence-word word-question ja"
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

    <div v-if="selectedSeq">
      <div v-if="selectedSegment.answer" class="answer-buttons">
        <div
          class="answer-button"
          :class="{
            red: selectedSegment.answer === 'incorrect',
            green: selectedSegment.answer === 'correct',
          }"
          @click="resetAnswer"
          v-shortkey="{
            reset: ['backspace'],
          }"
          @shortkey="shortkey"
        >
          RESET
          <div class="answer-details">
            Answered: {{ selectedSegment.answer }}
          </div>
        </div>
      </div>
      <div v-else class="answer-buttons">
        <div class="answer-button red" @click="setAnswer('incorrect')">NO</div>
        <div class="answer-button green" @click="setAnswer('correct')">YES</div>
      </div>

      <WordComponent :key="selectedSeq" :seq="selectedSeq" />
    </div>

    <div v-if="allAnswered && !selectedSeq && !loading">
      <div v-if="allAnswered" class="answer-buttons">
        <div class="answer-button blue" @click="submit">SUBMIT</div>
      </div>
      <div v-if="sentence.english" class="center-block" style="margin-top: 1em">
        Translation: {{ sentence.english }}
      </div>
    </div>
  </div>
</template>

<script setup>
  const route = useRoute()
  const env = useEnv()

  const sentence = ref({})
  const selectedIndex = ref()
  const loading = ref(false)

  const loadQuestion = async () => {
    const resp = await $fetch('/api/question', {
      params: {
        drill_id: route.params.drill_id,
        type:     route.params.type,
      },
    })
    const json = JSON.parse(resp)

    let componentIndex = 1
    for (const segment of json.structure)
      if (segment.seq) {
        segment.answer = null
        segment.index = componentIndex++
      }

    loading.value = false

    return json
  }

  // TODO: Use 'useAsyncData' hook
  loadQuestion().then(json => sentence.value = json)

  env.setActivityGroup('srs')
  env.setQuizParams(route.params)

  const segments = computed(() => {
    return sentence.value.structure || []
  })

  const selectedSegment = computed(() => {
    return selectedIndex !== null
      ? segments.value[selectedIndex.value]
      : null
  })

  const selectedSeq = computed(() => {
    return selectedSegment.value ? selectedSegment.value.seq : null
  })

  const allAnswered = computed(() => {
    const mainWord = segments.value.find((i) => i.highlight === true)
    if (mainWord !== undefined) {
      return mainWord.answer !== null
    } else {
      const unanswered = segments.value.filter((i) => i.seq && !i.answer)
      return !!(unanswered.length === 0 && segments.value.length !== 0)
    }
  })

  const shortkey = (event) => {
    if (selectedSegment.value) {
      if (event.srcKey === 'correct' || event.srcKey === 'incorrect') {
        setAnswer(event.srcKey, false)
      } else if (event.srcKey === 'esc') {
        selectedIndex.value = null
      } else if (event.srcKey === 'reset') {
        resetAnswer()
      }
    }
    if (event.srcKey === 'space') {
      selectHighlighted()
    } else if (event.srcKey === 'enter' && !!allAnswered.value) {
      selectedIndex.value = null
      submit()
    }
  }

  const selectWord = (sentenceIndex) => {
    selectedIndex.value =
      selectedSeq.value &&
      selectedSeq.value === segments.value[sentenceIndex].seq
        ? null
        : sentenceIndex
  }

  const selectHighlighted = () => {
    const i = segments.value.findIndex((s) => s.highlight === true)
    selectWord(i !== -1 ? i : 0) // select highlighted or first
  }

  const setAnswer = (answerText, unselect = true) => {
    selectedSegment.value.answer = answerText
    if (unselect) selectedIndex.value = null
  }

  const resetAnswer = () => {
    selectedSegment.value.answer = null
  }

  const submit = async () => {
    loading.value = true
    const answers = segments.value
      .filter((i) => i.seq)
      .map(function (i) {
        return { seq: i.seq, base: i.base, answer: i.answer }
      })

    try {
      await $fetch('/api/quiz', {
        method: 'POST',
        body: {
          drill_id:    route.params.drill_id,
          type:        route.params.type,
          sentence_id: sentence.value.id,
          answers,
        },
      })

      sentence.value = await loadQuestion()
    } catch (e) {
      alert(e)
    }
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
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      font-weight: bold;
      letter-spacing: 0.15em;
      padding: 0.5em 1em;
      cursor: pointer;
      text-align: center;
      min-height: 2em;
      grid-column: auto;
      grid-row: 1;

      .answer-details {
        font-size: x-small;
        letter-spacing: 0em;
        margin: -0.3em 0 -0.2em 0;
        opacity: 0.6;
      }
    }
  } /* end of .answer-buttons */
} /* end of #sentence-quiz-app */

html[class~='dark-mode'] body {
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
