//import Vue from 'vue/dist/vue.js';
const axios = require('axios');
import helpers from './helpers.js';
const radicalsList = helpers.radicalsList();

Vue.component('vue-kanji', {
  props: {
    id: {type: Number, required: true},
    j: {type: Object, required: true},
    editing: {type: Boolean, required: true}
  },
  data() {
    return {
      readings: {},
      readingsFetched: false,
    }
  },
  computed: {
    kanji() {
      return this.j.kanjis.find(i => i.id === this.id);
    },
    comment() {
      return this.kanji.progress ? this.kanji.progress.comment : null;
    },
    classicalRadical() {
      return radicalsList[this.kanji.radnum - 1];
    },
    learned() {
      return this.kanji.progress.learned_at ? true : false;
    },
    htmlClass() {
      return [
        'grade-' + (this.kanji.grade || 'no'),
        this.learned ? 'learned' : null
      ]
    },
    gradeText(){
      var grade = this.kanji.grade;
      if (grade >=1 && grade <= 6) {
        return [null, '１', '２', '３', '４', '５', '６'][grade] + '年';
      } else if (grade == 8) {
        return '常用';
      } else if (grade == 9 || grade == 10) {
        return '人名';
      } else {
        return '表外';
      }
    },
  },
  methods: {
    radicalById(id) {
      return this.j.radicals.find(i => i.id === id);
    },
    updateProgress(progress) {
      this.j.kanjis.find(i => i.id === this.id).progress = progress;
    },
    search() {
      this.$emit('search', this.kanji.title);
    },
    setComment(progress) {
      this.kanji.progress = JSON.parse(progress);
    },
    fetchReadings() {
      const app = this;
      const formData = new FormData();
      formData.append('kanji', this.kanji.title);

      axios.post('/api/kanji_readings', formData
      ).then(function(resp) {
        app.readingsFetched = true;
        app.readings = resp.data;
      })
    },
    ...helpers
  },
  template: `
<div class="vue-kanji">
  <div class="kanji-info-table">
    <div class="kanji-title no-refocus" :class="htmlClass" @click="search">{{kanji.title}}<div class="kanji-grade">{{gradeText}}</div></div>
    <div class="kanji-details">
      <div class="nb" v-if="kanji.jlptn">&#x1f4ae; N{{kanji.jlptn}}</div>
      <div class="nb" v-if="kanji.wk_level">&#x1f980; {{kanji.wk_level}}</div>
      <div class="radical-label">部首</div><span class="nb">{{classicalRadical}}</span>
      <a :href="'https://wakame.fruitcode.net/jiten/?book=kanji&search=' + kanji.title" target="_blank">&#x1f50e;</a>

      <template v-if="kanji.links"><div class="naritachi-label">成立</div><a v-for="(urlHash, idx) of kanji.links.ishiseiji" :href="'https://blog.goo.ne.jp/ishiseiji/e/' + urlHash" target="_blank">{{kanji.title}}</a></template><br>

      <template v-for="(v, idx) of kanji.on"><div class="nb"><div v-if="idx === 0" class="on-label">音</div>{{v}}</div><template v-if="idx !== kanji.on.length - 1"> · </template></template>
      <template v-for="(v, idx) of kanji.kun"><div class="nb"><div v-if="idx === 0" class="kun-label">訓</div>{{v.split('.')[0]}}<span class="okurigana" v-if="v.split('.').length > 1">{{v.split('.')[1]}}</span></div><template v-if="idx !== kanji.kun.length - 1"> · </template></template>
      <div v-if="!readingsFetched" @click="fetchReadings()" class="ajax-link no-refocus same-readings-label">⋯</div>

      <div v-if="readingsFetched">
        <vue-learn-buttons v-if="editing" :paths="j.paths" :progress="kanji.progress" :post-data="{id: kanji.id, title: kanji.title, kind: 'k'}" :editing="editing" v-on:update-progress="updateProgress($event)"></vue-learn-buttons>
        <table class="same-readings-table">
          <tr v-for="reading of Object.keys(readings)">
            <td><div class="nb">{{reading}}</div></td>
            <td><template v-for="k in readings[reading]">{{k[0]}}</template></td>
          </tr>
        </table>
      </div>
    </div>
  </div>

  <div v-if="kanji.english">&#x1f1ec;&#x1f1e7; {{kanji.english.join("; ")}}</div>

  <div v-if="false && kanji.wk_level">
    <div class="hr-title"><span>Meaning</span></div>
    <div class="mnemonics">
      <span class="emphasis">{{kanji.wk_meaning}}</span>
      <span v-html="stripBB(kanji.mmne)"></span>
      <span class="hint" v-if="kanji.mhnt" v-html="stripBB(kanji.mhnt)"></span>
    </div>

    <div class="hr-title"><span>Reading</span></div>
    <div class="mnemonics">
      <span class="emphasis">{{kanji.wk_readings.join(', ')}}</span>
      <span v-html="stripBB(kanji.rmne)"></span>
      <span class="hint" v-if="kanji.rhnt" v-html="stripBB(kanji.rhnt)"></span>
    </div>
  </div>

  <vue-editable-text class="word-comment-form center-block" :post-url="j.paths.comment" :post-params="{kanji: kanji.title}" :text-data="comment" :editing="editing" placeholder="Add comment" @updated="setComment($event)"></vue-editable-text>

</div>
`
});
