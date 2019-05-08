//import Vue from 'vue/dist/vue.js';

import helpers from './helpers.js';

Vue.component('radical', {
  props: {
    id: {type: Number, required: true},
    j: {type: Object, required: true},
    editing: {type: Boolean, required: true}
  },
  computed: {
    radical() {
      return this.j.radicals.find(i => i.id === this.id);
    },
    kanjiSummaries() {
      this.radical.kanji_ids.map
      return this.radical.kanji_ids.map(i => this.j.kanji_summary.find(j => j.wk_id === i))
    }
  },
  methods: {
    updateProgress(progress) {
      this.j.radicals.find(i => i.id === this.id).progress = progress;
    },
    ...helpers
  },
  template: `
<div class="vue-radical">
  <span class="radical-title" :class="radical.progress.html_class">
    <span v-if="radical.title">{{radical.title}}</span>
    <span v-else v-html="radical.svg"></span>
  </span>
  <span>{{radical.meaning}} (WK#{{radical.level}})</span>

  <learn-buttons :paths="j.paths" :progress="radical.progress" :post-data="{id: radical.id, title: radical.title, kind: 'r'}" :editing="editing" v-on:update-progress="updateProgress($event)"></learn-buttons>

  <div class="hr-title"><span>Meaning</span></div>
  <div v-html="stripBB(radical.nmne)"></div>

  <div v-if="radical.progress.details" class="radical-meaning">
    <div class="hr-title"><span>User's data</span></div>
    <span v-if="radical.progress.details.t">【{{radical.progress.details.t}}】</span>
    <span v-if="radical.progress.details.m" v-html="stripBB(radical.progress.details.m)"></span>
  </div>

  <div v-if="radical.kanji_ids">
    <div class="hr-title"><span>Kanji</span></div>
    <div class="elements-list">
      <div v-for="kanji of kanjiSummaries" class="elements-list-item">
        <div class="element-block" :class="kanji.progress.html_class || 'locked'">
          <a :href="kanji.href">
            <div class="element">{{kanji.title}}</div>
            <div class="description">{{kanji.meaning}}</div>
          </a>
        </div>
      </div>
    </div>
  </div>
</div>
`
});
