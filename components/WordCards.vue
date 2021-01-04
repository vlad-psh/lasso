<template>
  <div v-if="cards.length > 0" class="word-details wk-info center-block">
    <div class="icon">&#x1f980;</div>
    <div class="expandable-list">
      <div
        v-for="(card, cardIndex) of cards"
        :key="card.meaning"
        class="expandable-list-item no-refocus"
      >
        <div class="wk-element" @click="openCard(card)">
          <span class="level">{{ card.level }}</span>
          {{ card.title }} ({{ card.meaning.split(',')[0] }})
        </div>
        <div
          v-if="cardIndex === selectedCard"
          class="expandable-list-arrow"
        ></div>
      </div>
    </div>

    <div
      v-if="selectedCard !== null"
      class="expandable-list-container word-gloss-expanded"
    >
      <div class="center-block">
        <span>{{ selectedCard.title }} · </span>
        <span style="font-style: italic">({{ selectedCard.pos }})</span>

        <div class="hr-title"><span>Meaning</span></div>
        <div class="mnemonics">
          <span class="emphasis">{{ selectedCard.meaning }}</span>
          <span>{{ selectedCard.mmne }}</span>
        </div>

        <div class="hr-title"><span>Reading</span></div>
        <div class="mnemonics">
          <span class="emphasis">{{ selectedCard.reading }}</span>
          <span>{{ selectedCard.rmne }}</span>
        </div>

        <div class="hr-title"><span>Example sentences</span></div>
        <ul>
          <li v-for="(sentence, idx) in selectedCard.sentences" :key="idx">
            {{ sentence.ja }}<br />{{ sentence.en }}
          </li>
        </ul>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  props: { cards: { type: Array, required: true } },
  data() {
    return { selectedCard: null }
  },
  methods: {
    openCard(card) {
      this.selectedCard = this.selectedCard === card ? null : card
    },
  },
}
</script>
