//import Vue from 'vue/dist/vue.js';

import helpers from './helpers.js';

Vue.component('kanji', {
  props: {
    kanji: {type: Object, required: true}
  },
  data(){
    return {
    }
  },
  methods: {
    ...helpers
  },
  template: `
<div class="vue-kanji">
  <span class="kanji-title">{{kanji.title}}</span>
  <span v-if="kanji.jlptn"> · JLPT N{{kanji.jlptn}}</span>
  <span v-if="kanji.wk_level"> · WK #{{kanji.wk_level}}</span>
  <span v-if="kanji.english">：{{kanji.english.join("; ")}}</span>
  <div>
    <span v-if="kanji.on">
      <span :class="kanji.emph === 'on' ? 'emph' : ''">【音読み】</span> {{ kanji.on.join(" · ") }}
    </span>
    <span v-if="kanji.kun">
      <span :class="kanji.emph === 'kun' ? 'emph' : ''">【訓読み】</span> {{ kanji.kun.join(" · ") }}</span>
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
</div>
`
});
