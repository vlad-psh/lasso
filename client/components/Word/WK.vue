<template>
  <div v-if="cards.length > 0" class="word-details wk-info center-block">
    <CrabIcon class="svg-icon" />

    <div v-for="card of cards" :key="card.title" class="wk-element">
      <span class="level">{{ card.level }}</span>
      <span class="ja">{{ card.title }}</span> ・
      <span class="en">{{ card.meaning.split(',')[0] }}</span>
      <ul>
        <li v-for="(sentence, idx) in card.sentences" :key="idx">
          <span class="ja">{{ sentence.ja }}</span>
          <br />
          <span class="en">{{ sentence.en }}</span>
        </li>
      </ul>
    </div>
  </div>
</template>

<script setup>
  import CrabIcon from '../../assets/icons/crab.svg'

  defineProps({
    cards: { type: Array, required: true },
  })
</script>

<style lang="scss">
.wk-info {
  padding: 0.4em;

  .svg-icon {
    float: left;
    margin-right: 0.5em;
  }
}
.wk-element {
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
  ul {
    list-style-type: none;
    margin: 0;
    padding: 0;
    font-size: 0.9em;
    line-height: initial;
    li {
      margin: 0.3em 0 0.3em 0;
    }
  }
}

.emphasis {
  background: #7774;
  color: inheirt;
  border-radius: 3px;
  padding: 0 0.4em;
}

.hr-title {
  display: block;
  text-align: center;
  overflow: hidden;
  white-space: nowrap;
  color: #bbb;
  font-size: 0.8em;

  & > span {
    position: relative;
    display: inline-block;
  }
  & > span:before,
  & > span:after {
    content: '';
    position: absolute;
    top: 50%;
    width: 9999px;
    height: 1px;
    background: rgba(128, 128, 128, 0.2);
  }
  & > span:before {
    right: 100%;
    margin-right: 15px;
  }
  & > span:after {
    left: 100%;
    margin-left: 15px;
  }
} /* end of .hr-title */
</style>
