//import Vue from 'vue/dist/vue.js';

import helpers from './helpers.js';

Vue.component('kanji', {
  props: {
    id: {type: Number, required: true},
    j: {type: Object, required: true}
  },
  computed: {
    kanji() {
      return this.j.kanjis.find(i => i.id === this.id);
    }
  },
  methods: {
    radicalById(id) {
      return this.j.radicals.find(i => i.id === id);
    },
    ...helpers
  },
  template: `
<div class="vue-kanji">
  <span class="kanji-title" :class="kanji.progress.html_class">{{kanji.title}}</span>
  <span v-if="kanji.jlptn">JLPT N{{kanji.jlptn}}</span>
  <span v-if="kanji.wk_level"> · WK #{{kanji.wk_level}}</span>
  <span v-if="kanji.english">：{{kanji.english.join("; ")}}</span>
  <div>
    <span v-if="kanji.on">【音読み】{{ kanji.on.join(" · ") }}</span>
    <span v-if="kanji.kun">【訓読み】{{ kanji.kun.join(" · ") }}</span>
    <span v-if="kanji.nanori">【名乗り】{{ kanji.nanori.join(" · ") }}</span>
  </div>
  <div v-if="kanji.wk_level" class="kanji-meaning">
    <span style="font-weight: bold">Meaning: </span>
    <span v-html="stripBB(kanji.mmne)"></span>
    <span class="hint" v-html="stripBB(kanji.mhnt)"></span>
  </div>
  <div v-if="kanji.wk_level" class="kanji-reading">
    <span style="font-weight: bold">Reading: </span>
    <span v-html="stripBB(kanji.rmne)"></span>
    <span class="hint" v-html="stripBB(kanji.rhnt)"></span>
  </div>
  <div v-if="kanji.progress.details" class="kanji-reading">
    <span style="font-weight: bold">Comment: </span>
    <span v-if="kanji.progress.details.t">【{{kanji.progress.details.t}}】</span>
    <span v-if="kanji.progress.details.r" v-html="stripBB(kanji.progress.details.r)"></span>
    <span v-if="kanji.progress.details.m" v-html="stripBB(kanji.progress.details.m)"></span>
  </div>
  <div v-if="kanji.radicals" class="kanji-reading">
    <span style="font-weight: bold">Radicals: </span>
    <span v-for="radicalId in kanji.radicals">{{radicalById(radicalId).meaning}}, </span>
  </div>
</div>
`
});
