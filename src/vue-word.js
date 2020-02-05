import helpers from './helpers.js';

Vue.component('vue-word', {
  props: {
    seq: {type: Number, required: true},
    j: {type: Object, required: true},
    editing: {type: Boolean, required: true}
  },
  data() {
    return {
      forms: {card: null, kreb: null, selectedDrill: null, kanjiIndex: null},
      bullets: "①②③④⑤⑥⑦⑧⑨⑩⑪⑫⑬⑭⑮⑯⑰⑱⑲⑳㉑㉒㉓㉔㉕㉖㉗㉘㉙㉚㉛㉜㉝㉞㉟㊱㊲㊳㊴㊵㊶㊷㊸㊹㊺㊻㊼㊽㊾㊿".split('')
    }
  },
  computed: {
    w() {
      return this.j.words.find(i => i.seq === this.seq);
    },
    kanjis() {
      var krebsString = this.w.krebs.map(i => i.title).join('');
      return this.j.kanjis.filter(i => krebsString.indexOf(i.title) !== -1).map(i => i.title);
    },
    selectedCard() {
      if (this.forms.card !== null) {
        return this.w.cards[this.forms.card];
      } else {
        return {};
      }
    },
    selectedKreb() {
      if (this.forms.kreb !== null) {
        return this.w.krebs.find(i => i.title === this.forms.kreb);
      } else {
        return {};
      }
    },
    selectedKrebProgress() {
      if (this.forms.kreb !== null) {
        return this.selectedKreb.progress;
      } else {
        return {};
      }
    },
  },
  methods: {
    openKrebForm(kreb) {
      this.forms.kreb = this.forms.kreb === kreb ? null : kreb;
    },
    openCardForm(cardIndex) {
      this.forms.card = this.forms.card === cardIndex ? null : cardIndex;
    },
    openKanji(kanjiIndex) {
      this.forms.kanjiIndex = this.forms.kanjiIndex === kanjiIndex ? null : kanjiIndex;
    },
    updateKrebProgress(progress) {
      this.w.krebs.find(i => i.title === this.forms.kreb).progress = progress;
    },
    addKrebToDrill() {
      if (this.selectedKreb.drills.indexOf(this.forms.selectedDrill) === -1) {
        $.ajax({
          url: this.j.paths.drill,
          method: "POST",
          data: {
            kind: 'w',
            id: this.w.seq,
            title: this.selectedKreb.title,
            drill_id: this.forms.selectedDrill
          }
        }).done(data => {
          this.selectedKreb.drills.push(this.forms.selectedDrill);
        });
      }
    },
    search(query, method) {
      this.$emit('search', query, method);
    },
    ...helpers
  }, // end of methods
  updated() {
  },
  template: `
  <div class="vue-word word-card" id="word-card-app">

    <!-- list of krebs -->
    <div class="center-block">
      <div class="word-krebs expandable-list">
        <div class="expandable-list-item" v-for="kreb of w.krebs">
          <div>
            <div class="word-kreb no-refocus" :class="[kreb.is_common ? 'common' : null, kreb.progress.learned_at ? 'learned' : null]" @click="openKrebForm(kreb.title)"><vue-pitch-word :word="kreb.title" :pitch="kreb.pitch"></vue-pitch-word><div v-if="kreb.progress.learned_at && false" class="learned-icon">&#x1f514;</div></div>
          </div>
          <div class="expandable-list-arrow" v-if="kreb.title === forms.kreb"></div>
        </div>
      </div>
    </div>

    <!-- expanded word properties -->
    <div class="expandable-list-container word-kreb-expanded" v-if="forms.kreb !== null">
      <div class="center-block">
        <table><tr>
          <td v-if="selectedKreb.pitch">Pitch: {{selectedKreb.pitch}}</td>
          <td><vue-learn-buttons :paths="j.paths" :progress="selectedKrebProgress" :post-data="{id: seq, title: forms.kreb, kind: 'w'}" :editing="editing" v-on:update-progress="updateKrebProgress($event)"></vue-learn-buttons></td>
          <td>Drills: {{selectedKreb.drills.map(i => j.drills.find(k => k.id === i).title)}}; Add:</td>
          <td><vue-dropdown :options="j.drills.filter(i => i.is_active === true)" empty-item="Select..." :selected-value="forms.selectedDrill" @selected="forms.selectedDrill = $event" value-key="id"></vue-dropdown></td>
          <td><input type="button" value="Add" @click="addKrebToDrill()"></td>
        </tr></table>
      </div>
    </div>

    <!-- list of used kanjis -->
    <div class="word-details center-block" v-if="kanjis.length > 0">
      <div class="expandable-list word-kanjis">
        <template v-for="(kanji, kanjiIndex) of j.kanjis">
          <div class="expandable-list-item" v-if="kanjis.indexOf(kanji.title) !== -1">
            <div class="wk-element no-refocus" @click="openKanji(kanjiIndex)"><vue-kanji-card :kanji="kanji.title" :grade="kanji.grade" :learned="kanji.progress.learned_at ? true : false"></vue-kanji-card></div>
            <div class="expandable-list-arrow" v-if="kanjiIndex === forms.kanjiIndex"></div>
          </div>
        </template>
      </div>
    </div>

    <!-- expanded kanji details -->
    <div class="expandable-list-container word-kreb-expanded" v-if="forms.kanjiIndex !== null">
      <div class="center-block">
        <vue-kanji :id="j.kanjis[forms.kanjiIndex].id" :j="j" :editing="editing" :key="forms.kanjiIndex" @search="search"></vue-kanji>
      </div>
    </div>

    <!-- english glossary -->
    <div class="word-details center-block">
      <div class="icon">&#x1f1ec;&#x1f1e7;</div>
      <span v-for="(gloss, glossIndex) of w.en">
        <span v-if="w.en.length > 1">{{bullets[glossIndex]}} </span>
        <span class="pos" v-if="gloss.pos">{{gloss.pos.map(i => i.replace(/^.(.*).$/, "$1")).join(", ")}} </span>
        {{gloss.gloss.join(', ')}} 
      </span>
    </div>

    <!-- russian glossary -->
    <div class="word-details center-block" v-if="w.ru && w.ru.length > 0">
      <div class="icon">&#x1f1f7;&#x1f1fa;</div>
      <span v-for="(gloss, glossIndex) of w.ru">
        <span v-if="w.ru.length > 1">{{bullets[glossIndex]}} </span>
        <span class="pos" v-if="gloss.pos">{{gloss.pos.map(i => i.replace(/^.(.*).$/, "$1")).join(", ")}} </span>
        {{gloss.gloss.join(', ')}} 
      </span>
    </div>

    <div class="word-details center-block" v-if="w.nhk_data">
      <div class="icon-nhk"></div><vue-pitch-word-nhk :j="w.nhk_data"></vue-pitch-word-nhk>
    </div>

    <div class="word-details wk-info center-block" v-if="w.cards.length > 0">
      <div class="icon">&#x1f980;</div>
      <div class="expandable-list">
        <div class="expandable-list-item" v-for="(card, cardIndex) of w.cards">
          <div class="wk-element" @click="openCardForm(cardIndex)">
            <span class="level">{{card.level}}</span>
            {{card.title}} ({{card.meaning.split(',')[0]}})
          </div>
          <div class="expandable-list-arrow" v-if="cardIndex === forms.card"></div>
        </div>
      </div>
    </div>

    <div class="expandable-list-container word-gloss-expanded" v-if="forms.card !== null">
      <div class="center-block">
        <span>{{selectedCard.title}} · </span>
        <span style="font-style: italic">({{selectedCard.pos}})</span>

        <div class="hr-title"><span>Meaning</span></div>
        <div class="mnemonics">
          <span class="emphasis">{{selectedCard.meaning}}</span>
          <span v-html="stripBB(selectedCard.mmne)"></span>
        </div>

        <div class="hr-title"><span>Reading</span></div>
        <div class="mnemonics">
          <span class="emphasis">{{selectedCard.reading}}</span>
          <span v-html="stripBB(selectedCard.rmne)"></span>
        </div>

        <div class="hr-title"><span>Example sentences</span></div>
        <ul>
          <li v-for="sentence in selectedCard.sentences">{{sentence.ja}}<br>{{sentence.en}}</li>
        </ul>
      </div>
    </div>

    <vue-editable-text class="word-comment-form center-block" :post-url="j.paths.comment" :post-params="{seq: w.seq}" :text-data="w.comment" :editing="editing" placeholder="Add comment" @updated="w.comment = $event"></vue-editable-text>

  </div>
`
});
