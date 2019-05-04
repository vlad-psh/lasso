import helpers from './helpers.js';

Vue.component('word', {
  props: {
    seq: {type: Number, required: true},
    j: {type: Object, required: true},
    editing: {type: Boolean, required: true}
  },
  data() {
    return {
      forms: {card: null, kreb: null, comment: null, drillTitle: ''},
      bullets: "①②③④⑤⑥⑦⑧⑨⑩⑪⑫⑬⑭⑮⑯⑰⑱⑲⑳㉑㉒㉓㉔㉕㉖㉗㉘㉙㉚㉛㉜㉝㉞㉟㊱㊲㊳㊴㊵㊶㊷㊸㊹㊺㊻㊼㊽㊾㊿".split('')
    }
  },
  computed: {
    w() {
      return this.j.words.find(i => i.seq === this.seq);
    },
    selectedCard() {
      if (this.forms.card !== null) {
        return this.w.cards[this.forms.card];
      } else {
        return {};
      }
    },
    selectedKrebProgress() {
      if (this.forms.kreb !== null) {
        return this.w.krebs.find(i => i.title === this.forms.kreb).progress;
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
      var sentenceUrl = isRawSentence ? this.w.rawSentences[idx].href : this.w.sentences[idx].href;
      if (ask) {
        $.ajax({
          url: sentenceUrl,
          method: "DELETE"
        }).done(data => {
          if (isRawSentence) {
            this.w.rawSentences = this.w.rawSentences.filter(i => i.href != sentenceUrl);
          } else {
            this.w.sentences = this.w.sentences.filter(i => i.href != sentenceUrl);
          }
        });
      };
    },
    learnWord(kreb) {
      $.ajax({
        url: this.j.paths.learn,
        method: "POST",
        data: {seq: this.w.seq, kreb: kreb}
      }).done(data => {
        this.w.krebs.find(i => i.title === kreb).progress = JSON.parse(data);
      });
    },
    burnWord(kreb, progressId) {
      $.ajax({
        url: this.j.paths.burn,
        method: "POST",
        data: {progress_id: progressId}
      }).done(data => {
        this.w.krebs.find(i => i.title === kreb).progress = JSON.parse(data);
      });
    },
    flagWord(kreb) {
      $.ajax({
        url: this.j.paths.flag,
        method: "POST",
        data: {seq: this.w.seq, kreb: kreb}
      }).done(data => {
        this.w.krebs.find(i => i.title === kreb).progress = JSON.parse(data);
      });
    },
    saveComment() {
      $.ajax({
        url: this.j.paths.comment,
        data: {seq: this.w.seq, comment: this.w.comment},
        method: "POST"
      }).done(data => {
        this.forms.comment = false;
      });
    },
    showCommentForm() {
      this.forms.comment = true;
    },
    hideCommentForm() {
      this.forms.comment = false;
    },
    openKrebForm(kreb) {
      if (this.forms.kreb === kreb) {
        this.forms.kreb = null;
      } else {
        this.forms.kreb = kreb;
      }
    },
    openCardForm(cardIndex) {
      if (this.forms.card === cardIndex) {
        this.forms.card = null;
      } else {
        this.forms.card = cardIndex;
      }
    },
    addToDrill(kreb) {
      var app = this;
      $.ajax({
        url: this.j.paths.drill,
        method: "POST",
        data: {drillTitle: this.forms.drillTitle, seq: this.w.seq, kreb: kreb}
      }).done(data => {
        alert(data);
      });
    },
    ...helpers
  }, // end of methods
  updated() {
    $('.word-connection-autocomplete').autocomplete({
      source: this.j.paths.autocomplete,
      minLength: 1,
      select: wordConnectionAutocompleteSelect
    });
  },
  template: `
  <div class="word-card" id="word-card-app">

    <div class="word-krebs center-block expandable-list">
      <div class="expandable-list-item" v-for="kreb of w.krebs">
        <div>
          <div class="word-kreb" :class="[kreb.progress.html_class, kreb.is_common ? 'word-kreb-common' : null]" @click="openKrebForm(kreb.title)">{{kreb.title}}</div>
        </div>
        <div class="expandable-list-arrow" v-if="kreb.title === forms.kreb"></div>
      </div>
    </div>

    <div class="expandable-list-container word-kreb-expanded" v-if="forms.kreb !== null">
      <div class="center-block">
        <div>
          Status:

          <span v-if="editing && !selectedKrebProgress.flagged_at">
            <a @click="flagWord(forms.kreb)" class="button">flag!</a>
          </span>
          <span v-else-if="selectedKrebProgress.flagged_at">flagged</span>

          <span v-if="editing && !selectedKrebProgress.learned_at && !selectedKrebProgress.burned_at">
            <a @click="learnWord(forms.kreb)" class="button">learn!</a>
          </span>
          <span v-else-if="selectedKrebProgress.learned_at">learned</span>

          <span v-if="editing && selectedKrebProgress.learned_at && !selectedKrebProgress.burned_at">
            <a @click="burnWord(forms.kreb, selectedKrebProgress.id)" class="button">burn!</a>
          </span>
          <span v-else-if="selectedKrebProgress.burned_at">burned</span>

          <span v-if="editing">
            <input type="text" v-model="forms.drillTitle" @keyup.enter="addToDrill(forms.kreb)">
          </span>
        </div>

        <div v-for="kanji of j.kanjis" v-if="forms.kreb.indexOf(kanji.title) !== -1">
          <kanji :id="kanji.id" :j="j"></kanji>
        </div>
      </div>
    </div>

    <div class="word-glosses center-block">
      <div class="word-gloss-flag">&#x1f1ec;&#x1f1e7;</div>
      <span v-for="(gloss, glossIndex) of w.en">
        <span v-if="w.en.length > 1">{{bullets[glossIndex]}} </span>
        <span class="word-gloss-pos" v-if="gloss.pos">{{gloss.pos.map(i => i.replace(/^.(.*).$/, "$1")).join(", ")}} </span>
        {{gloss.gloss.join(', ')}} 
      </span>
    </div>
    <div class="word-glosses center-block" v-if="w.ru && w.ru.length > 0">
      <div class="word-gloss-flag">&#x1f1f7;&#x1f1fa;</div>
      <span v-for="(gloss, glossIndex) of w.ru">
        <span v-if="w.ru.length > 1">{{bullets[glossIndex]}} </span>
        <span class="word-gloss-pos" v-if="gloss.pos">{{gloss.pos.map(i => i.replace(/^.(.*).$/, "$1")).join(", ")}} </span>
        {{gloss.gloss.join(', ')}} 
      </span>
    </div>

    <div class="word-glosses center-block" v-if="w.cards.length > 0">
      <div class="word-gloss-flag">&#x1f980;</div>
      <div class="expandable-list" style="display: inline-block">
        <div class="expandable-list-item" v-for="(card, cardIndex) of w.cards">
          <div class="word-gloss" @click="openCardForm(cardIndex)">
            <div class="level-wrapper">{{card.level}}</div>
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
      </div>
    </div>

    <div v-if="editing" class="word-comment-form center-block">
      <div v-if="forms.comment">
        <textarea id="word-comment-textarea" v-model="w.comment" @keyup.esc="hideCommentForm"></textarea>
        <input type="button" value="Save" @click="saveComment">
      </div>
      <div class="editable-text" v-else-if="w.comment" @click="showCommentForm">
        <p v-for="commentLine of w.comment.split('\\n')">{{commentLine}}</p>
      </div>
      <div class="editable-text" v-else style="font-style: italic; color: rgba(128,128,128,0.7)" @click="showCommentForm">Add comment</div>
    </div>
    <div v-else-if="w.comment" class="word-comment-form center-block">
      <p v-for="commentLine of w.comment.split('\\n')">{{commentLine}}</p>
    </div>

    <div v-if="editing" class="center-block" style="margin-top: 0.8em; margin-bottom: 0.8em">
      <span style="font-weight: bold">Contains:</span>
      <div class="connected-word" v-for="(sw, swIndex) of w.shortWords">
        <a :href="sw.href">{{sw.title}}</a>
        <span class="action-buttons">[<a @click="deleteConnectedWord('short', swIndex)">消す</a>]</span>
      </div>
      <div class="connected-word-none" v-if="!w.shortWords.length">none</div>
      <input class="word-connection-autocomplete" type="text" data-word-type="short" placeholder="Add short">

      <span style="font-weight: bold">Belongs to:</span>
      <div class="connected-word" v-for="(sw, swIndex) of w.longWords">
        <a :href="sw.href">{{sw.title}}</a>
        <span class="action-buttons">[<a @click="deleteConnectedWord('long', swIndex)">消す</a>]</span>
      </div>
      <div class="connected-word-none" v-if="!w.longWords.length">none</div>
      <input class="word-connection-autocomplete" type="text" data-word-type="long" placeholder="Add long">
    </div>

    <div v-if="editing" class="center-block">
      <div style="opacity: 0.5; font-size: 0.6em; text-align: justify">&#x2139;&#xfe0f; Add only those words, which doesn't form new senses or readings when connected. GOOD examples: 電子＋書籍、図書館＋員. BAD examples: 料理＋人 (reading of 人 can be tricky; we should memorize full word 料理人), 一＋週間 (same here for 一; you may want mark this as 'burned' right away if you wish), 食料＋品 (new sense formed: food + articles = groceries; also, reading of 品 can be ひん or ぴん; you can mark 食料 as 'burned' if you want to reduce count of reviewing words)</div>
    </div>

    <div class="hr-title center-block" v-if="editing && (w.sentences.length > 0 || w.rawSentences.length > 0)">
      <span style="margin: 1em 0">Sentences</span>
    </div>

    <div class="word-sentences word-sentences-structured center-block" v-if="editing && w.sentences.length > 0">
      <span v-for="(s, sIndex) of w.sentences">
        {{bullets[sIndex]}} {{s.jp}}
        <span style="font-size: small">《{{s.en}}》</span>
        <span class="action-buttons">[<a class="remove-sentence-button" @click="removeSentence(sIndex, false)">消す</a>]</span>
      </span>
    </div>

    <div class="word-sentences center-block" v-if="editing && w.rawSentences.length > 0">
      <span v-for="(s, sIndex) of w.rawSentences">
        {{bullets[sIndex]}} {{s.jp}}
        <span style="font-size: small">《{{s.en}}》</span>
        <span class="action-buttons">[<a class="remove-sentence-button" @click="removeSentence(sIndex, true)">消す</a>]</span>
      </span>
    </div>

  </div>
`
});

function wordConnectionAutocompleteSelect(event, ui) {
  var wordType = $(this).data('word-type');
  var postData = {};
  postData[wordType] = ui.item.id;
  postData[wordType === 'short' ? 'long' : 'short'] = wordApp.seq;

  $.ajax({
    url: wordApp.j.paths.connect,
    method: 'POST',
    data: postData
  }).done(data => {
    wordApp.addConnectedWord(wordType, {seq: ui.item.id, title: ui.item.title, href: ui.item.href});
    $(this).val('');
  });

  return false;
}
