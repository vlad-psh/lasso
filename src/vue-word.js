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
    addConnectedWord(wordType, word) {
      if (wordType === 'short') {
        this.w.shortWords.push(word);
      } else {
        this.w.longWords.push(word);
      }
    },
    deleteConnectedWord(wordType, wordIndex) {
      var word = wordType === 'short' ? this.w.shortWords[wordIndex] : this.w.longWords[wordIndex];
      var postData = {};
      postData[wordType] = word.seq;
      postData[wordType === 'short' ? 'long' : 'short'] = this.w.seq;

      var ask = confirm(`Are you sure you want to delete ${word.title}?`);
      if (ask) {
        $.ajax({
          url: this.j.paths.connect,
          method: "DELETE",
          data: postData
        }).done(data => {
          if (wordType === 'short') {
            this.w.shortWords = this.w.shortWords.filter(i => i.seq != word.seq);
          } else {
            this.w.longWords = this.w.longWords.filter(i => i.seq != word.seq);
          }
        });
      }
    },
    removeSentence(idx, isRawSentence) {
      var ask = confirm("Are you sure?");
      var sentenceUrl = this.w.sentences[idx].href;
      if (ask) {
        $.ajax({
          url: sentenceUrl,
          method: "DELETE"
        }).done(data => {
          this.w.sentences = this.w.sentences.filter(i => i.href != sentenceUrl);
        });
      };
    },
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
    trimPitch(pitch){
      return pitch.replace(/\(.*?\)/g, '');
    },
    ...helpers
  }, // end of methods
  updated() {
  },
  template: `
  <div class="vue-word word-card" id="word-card-app">
    <div class="center-block">
      <div class="word-krebs expandable-list">
        <div class="expandable-list-item" v-for="kreb of w.krebs">
          <div>
            <div class="word-kreb" :class="[kreb.is_common ? 'common' : null, kreb.progress.learned_at ? 'learned' : null]" @click="openKrebForm(kreb.title)">{{kreb.title}}<span class="pitch" v-if="kreb.pitch" :title="kreb.pitch">{{trimPitch(kreb.pitch)}}</span><div v-if="kreb.progress.learned_at && false" class="learned-icon">&#x1f514;</div></div>
          </div>
          <div class="expandable-list-arrow" v-if="kreb.title === forms.kreb"></div>
        </div>
      </div>
    </div>

    <div class="expandable-list-container word-kreb-expanded" v-if="forms.kreb !== null">
      <div class="center-block">
        <table><tr>
          <td><vue-learn-buttons :paths="j.paths" :progress="selectedKrebProgress" :post-data="{id: seq, title: forms.kreb, kind: 'w'}" :editing="editing" v-on:update-progress="updateKrebProgress($event)"></vue-learn-buttons></td>
          <td>Drills: {{selectedKreb.drills.map(i => j.drills.find(k => k.id === i).title)}}; Add:</td>
          <td><vue-dropdown :options="j.drills.filter(i => i.is_active === true)" empty-item="Select..." :selected-value="forms.selectedDrill" @selected="forms.selectedDrill = $event" value-key="id"></vue-dropdown></td>
          <td><input type="button" value="Add" @click="addKrebToDrill()"></td>
        </tr></table>
      </div>
    </div>

    <div class="word-details center-block" v-if="kanjis.length > 0">
      <div class="icon">&#x1f58c;</div>
      <div class="expandable-list">
        <template v-for="(kanji, kanjiIndex) of j.kanjis">
          <div class="expandable-list-item" v-if="kanjis.indexOf(kanji.title) !== -1">
            <div class="wk-element" @click="openKanji(kanjiIndex)" :class="kanji.progress.learned_at ? 'learned' : null">{{kanji.title}}</div>
            <div class="expandable-list-arrow" v-if="kanjiIndex === forms.kanjiIndex"></div>
          </div>
        </template>
      </div>
    </div>

    <div class="expandable-list-container word-kreb-expanded" v-if="forms.kanjiIndex !== null">
      <div class="center-block">
        <vue-kanji :id="j.kanjis[forms.kanjiIndex].id" :j="j" :editing="editing"></vue-kanji>
      </div>
    </div>

    <div class="word-details center-block">
      <div class="icon">&#x1f1ec;&#x1f1e7;</div>
      <span v-for="(gloss, glossIndex) of w.en">
        <span v-if="w.en.length > 1">{{bullets[glossIndex]}} </span>
        <span class="pos" v-if="gloss.pos">{{gloss.pos.map(i => i.replace(/^.(.*).$/, "$1")).join(", ")}} </span>
        {{gloss.gloss.join(', ')}} 
      </span>
    </div>

    <div class="word-details center-block" v-if="w.ru && w.ru.length > 0">
      <div class="icon">&#x1f1f7;&#x1f1fa;</div>
      <span v-for="(gloss, glossIndex) of w.ru">
        <span v-if="w.ru.length > 1">{{bullets[glossIndex]}} </span>
        <span class="pos" v-if="gloss.pos">{{gloss.pos.map(i => i.replace(/^.(.*).$/, "$1")).join(", ")}} </span>
        {{gloss.gloss.join(', ')}} 
      </span>
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
        <div>
          <span class="emphasis">{{selectedCard.meaning}}</span>
          <span v-html="stripBB(selectedCard.mmne)"></span>
        </div>

        <div class="hr-title"><span>Reading</span></div>
        <div>
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

    <div class="hr-title center-block" v-if="editing && w.sentences.length > 0">
      <span style="margin: 1em 0">Sentences</span>
    </div>

    <div class="word-sentences word-sentences-structured center-block" v-if="editing && w.sentences.length > 0">
      <span v-for="(s, sIndex) of w.sentences">
        {{bullets[sIndex]}} {{s.jp}}
        <span style="font-size: small">《{{s.en}}》</span>
        <span class="action-buttons">[<a class="remove-sentence-button" @click="removeSentence(sIndex)">消す</a>]</span>
      </span>
    </div>

  </div>
`
});
