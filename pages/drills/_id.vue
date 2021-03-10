<template>
  <div class="drill-details middle-content">
    <h1>{{ drill.title }}</h1>

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
        <div :class="word.reading_class" class="element">
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
        <div :class="word.kanji_class" class="element">
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
      background-color: #a8dba8; /* #dd0093; */
      color: #357878; /* master border */
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
</style>
