<template>
  <div v-if="cards.length > 0" class="word-details wk-info center-block">
    <CrabIcon class="svg-icon" />

    <Modal v-for="card of cards" :key="card.meaning" class="no-refocus">
      <div class="wk-element">
        <span class="level">{{ card.level }}</span>
        {{ card.title }} ({{ card.meaning.split(',')[0] }})
      </div>

      <div slot="title">
        <span class="level">{{ card.level }}</span>
        <span
          >{{ card.title }} · {{ card.meaning.split(',')[0] }} ({{
            card.pos
          }})</span
        >
      </div>

      <div slot="content">
        <div class="hr-title"><span>Meaning</span></div>
        <div class="mnemonics">
          <span class="emphasis">{{ card.meaning }}</span>
          <span>{{ card.mmne }}</span>
        </div>

        <div class="hr-title"><span>Reading</span></div>
        <div class="mnemonics">
          <span class="emphasis">{{ card.reading }}</span>
          <span>{{ card.rmne }}</span>
        </div>

        <div class="hr-title"><span>Example sentences</span></div>
        <ul>
          <li v-for="(sentence, idx) in card.sentences" :key="idx">
            {{ sentence.ja }}<br />{{ sentence.en }}
          </li>
        </ul>
      </div>
    </Modal>
  </div>
</template>

<script>
import CrabIcon from '@/assets/icons/crab.svg?inline'

export default {
  components: { CrabIcon },
  props: { cards: { type: Array, required: true } },
}
</script>

<style lang="scss">
.wk-element {
  display: inline-block;
  cursor: pointer;
  border-bottom: 1px dashed #008ace;
  color: #008ace;

  &:hover {
    color: #c00;
    border-bottom-color: #c00;
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
