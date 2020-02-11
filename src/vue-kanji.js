//import Vue from 'vue/dist/vue.js';
import helpers from './helpers.js';

Vue.component('vue-kanji', {
  props: {
    id: {type: Number, required: true},
    j: {type: Object, required: true},
    editing: {type: Boolean, required: true}
  },
  data() {
    return {
      commonWordsFetched: false,
      commonWords: [],
    }
  },
  computed: {
    kanji() {
      return this.j.kanjis.find(i => i.id === this.id);
    },
    comment() {
      if (this.kanji.progress && this.kanji.progress.details) {
        return this.kanji.progress.details.m || null;
      }
      return null;
    }
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
    setComment(newComment) {
      // TODO: what if kanji hasn't had a progress data yet?
      this.kanji.progress.details.m = newComment;
    },
    ...helpers
  },
  template: `
<div class="vue-kanji">
  <div class="kanji-info-table">
    <div class="kanji-title" :class="kanji.progress.html_class || 'pristine'"><a :href="kanji.url">{{kanji.title}}</a></div>
    <div>
      <span v-if="kanji.jlptn">&#x1f4ae; N{{kanji.jlptn}}</span>
      <span v-if="kanji.wk_level">&#x1f980; {{kanji.wk_level}}</span>
      <span @click="search" class="no-refocus">&#x1f50d; <a>Search words</a></span>
      <div v-if="kanji.english">
        &#x1f1ec;&#x1f1e7; {{kanji.english.join("; ")}}
        <span v-if="kanji.progress.details && kanji.progress.details.t">&#x1f464; {{kanji.progress.details.t}}</span>
      </div>
      <div v-if="kanji.radicals" class="radicals-list">
        部首：<template v-for="radicalId in kanji.radicals">
          <a :class="radicalById(radicalId).progress.html_class || 'pristine'" :href="radicalById(radicalId).href">{{radicalById(radicalId).meaning}}</a>
          {{' '}}
        </template>
      </div>
    </div>
  </div>

  <vue-kanji-readings :kanji="kanji" :key="kanji.title"></vue-kanji-readings>
  <vue-learn-buttons v-if="editing" :paths="j.paths" :progress="kanji.progress" :post-data="{id: kanji.id, title: kanji.title, kind: 'k'}" :editing="editing" v-on:update-progress="updateProgress($event)"></vue-learn-buttons>

  <div v-if="kanji.wk_level">
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

  <div class="hr-title"><span>User's data</span></div>
  <vue-editable-text class="word-comment-form center-block" :post-url="j.paths.comment" :post-params="{kanji: kanji.title}" :text-data="comment" :editing="editing" placeholder="Add comment" @updated="setComment($event)"></vue-editable-text>

</div>
`
});
