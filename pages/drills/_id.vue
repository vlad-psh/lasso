<template>
  <div class="drill-details middle-content">
    <h1>
      {{ drill.title }}
      <NuxtLink :to="readingQuiz">📰</NuxtLink>
      <NuxtLink :to="writingQuiz">✍️</NuxtLink>
    </h1>

    <h3>
      reading
      <DoubleClickButton @click="reset('reading')"> reset </DoubleClickButton>
    </h3>
    <div class="elements-list">
      <div
        v-for="(word, idx) of words"
        :key="'word' + idx"
        class="element-container"
      >
        <div :class="word.progress.reading" class="element">
          {{ word.title }}
        </div>
      </div>
    </div>

    <h3>
      writing
      <DoubleClickButton @click="reset('kanji')"> reset </DoubleClickButton>
    </h3>
    <div class="elements-list">
      <div
        v-for="(word, idx) of words"
        :key="'word' + idx"
        class="element-container"
      >
        <div :class="word.progress.writing" class="element">
          {{ word.title }}
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import DoubleClickButton from '../../components/DoubleClickButton.vue'
export default {
  components: { DoubleClickButton },
  async asyncData({ $axios, params }) {
    const resp = await $axios.get(`/api/drill/${params.id}`)
    return resp.data
  },
  computed: {
    readingQuiz() {
      return {
        name: 'sub-quiz',
        params: { drill_id: this.drill.id, type: 'reading' },
      }
    },
    writingQuiz() {
      return {
        name: 'sub-quiz',
        params: { drill_id: this.drill.id, type: 'writing' },
      }
    },
  },
  methods: {
    async reset(group) {
      await this.$axios.patch(`/api/drill/${this.drill.id}`, {
        reset: group,
      })
      const data = await this.$options.asyncData(this.$root.$options.context)
      Object.assign(this.$data, data)
    },
  },
}
</script>

<style lang="scss">
.drill-details {
  h1 {
    a {
      text-decoration: none;
      opacity: 0.6;

      &:hover {
        opacity: 1;
      }
    }
  }
}
.elements-list {
  display: flex;
  flex-flow: row wrap;
  width: 100%;

  &::after {
    content: '';
    flex-grow: 1000000000;
  }
  .element-container {
    display: inline-block;
    min-width: 4em;
    text-align: center;
    font-size: 0.7em;
    font-weight: 100;
    flex: auto;

    .element {
      padding: 0.4em 0.3em;
      position: relative;
      font-size: 1.4em;
      line-height: 1.5em;
      border-width: 0 1px 1px 0;
      border-style: solid;
    }

    .pristine {
      background-color: rgba(157, 157, 157, 0.1); /*#f5f5f5*/
      color: #638686;
      border-color: #b4c6c6;
    }
    .apprentice {
      background-color: #a8dba8;
      color: #357878;
      border-color: #96c496;
    }
    .guru {
      background-color: #79bd9a; /* #882d9e; */
      color: #0b486b; /* enlightened bg */
      border-color: #6ca98a;
    }
    .master {
      background-color: #3b8686; /* #294ddb; */
      color: #c7e3c7;
      border-color: #357878;
    }
    .enlightened {
      background-color: #0b486b; /* #0093dd; */
      color: #79bd9a; /* guru bg */
      border-color: #094060;
    }
    .burned {
      /* gradient can be created here: http://www.patternify.com/ */
      // background: $pattern-burned repeat;
      // background-size: 3px 3px;
      background-color: #0b486b;
      color: #79bd9a;
      border-color: #022030;
    }
  }
} /* end of .elements-list */

html[class='dark-mode'] body .elements-list .element-container {
  .pristine {
    background-color: rgba(72, 72, 72, 0.14);
    color: #8799a5;
    border-color: #5da8c61f;
  }
}
</style>
