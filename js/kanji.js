//import Vue from 'vue/dist/vue.js';

import helpers from './helpers.js';

Vue.component('kanji', {
  props: {
    id: {type: Number, required: true},
    j: {type: Object, required: true},
    editing: {type: Boolean, required: true}
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
    updateProgress(progress) {
      this.j.kanjis.find(i => i.id === this.id).progress = progress;
    },
    ...helpers
  },
  template: `
<div class="vue-kanji">
  <div class="kanji-info-table">
    <div class="kanji-title" :class="kanji.progress.html_class">{{kanji.title}}</div>
    <div>
      <span v-if="kanji.jlptn">&#x1f4ae; N{{kanji.jlptn}}</span>
      <span v-if="kanji.wk_level">&#x1f980; {{kanji.wk_level}}</span>
      <div v-if="kanji.on">音：{{ kanji.on.join(" · ") }}</div>
      <div v-if="kanji.kun">訓：{{ kanji.kun.join(" · ") }}</div>
      <div v-if="kanji.nanori">名：{{ kanji.nanori.join(" · ") }}</div>
    </div>
    <div>
      <div v-if="kanji.english">
        &#x1f1ec;&#x1f1e7; {{kanji.english.join("; ")}}
        <span v-if="kanji.progress.details && kanji.progress.details.t">&#x1f464; {{kanji.progress.details.t}}</span>
      </div>
      <div v-if="kanji.radicals" class="radicals-list">
        部首：<template v-for="radicalId in kanji.radicals">
          <a :class="radicalById(radicalId).progress.html_class" :href="radicalById(radicalId).href">{{radicalById(radicalId).meaning}}</a>
          {{' '}}
        </template>
      </div>
    </div>
  </div>

  <learn-buttons :paths="j.paths" :progress="kanji.progress" :post-data="{id: kanji.id, title: kanji.title, kind: 'k'}" :editing="editing" v-on:update-progress="updateProgress($event)"></learn-buttons>

  <div v-if="kanji.wk_level">
    <div class="hr-title"><span>Meaning</span></div>
    <div>
      <span class="emphasis">{{kanji.wk_meaning}}</span>
      <span v-html="stripBB(kanji.mmne)"></span>
      <span class="hint" v-html="stripBB(kanji.mhnt)"></span>
    </div>

    <div class="hr-title"><span>Reading</span></div>
    <div>
      <span class="emphasis">{{kanji.wk_readings.join(', ')}}</span>
      <span v-html="stripBB(kanji.rmne)"></span>
      <span class="hint" v-html="stripBB(kanji.rhnt)"></span>
    </div>
  </div>

  <div v-if="kanji.progress.details && (kanji.progress.details.r || kanji.progress.details.m)">
    <div class="hr-title"><span>User's data</span></div>
    <span v-if="kanji.progress.details.r" v-html="stripBB(kanji.progress.details.r)"></span>
    <span v-if="kanji.progress.details.m" v-html="stripBB(kanji.progress.details.m)"></span>
  </div>
</div>
`
});
