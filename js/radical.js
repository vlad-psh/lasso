//import Vue from 'vue/dist/vue.js';

import helpers from './helpers.js';

Vue.component('radical', {
  props: {
    radical: {type: Object, required: true}
  },
  methods: {
    ...helpers
  },
  template: `
<div class="vue-radical">
  <span class="radical-title" :class="radical.progress.html_class">{{radical.title}}</span>
  <span>{{radical.details.en.join(', ')}}</span>
  <div class="radical-meaning">
    <span style="font-weight: bold">Meaning: </span>
    <span v-html="stripBB(radical.details.nmne)"></span>
    <span class="hint" v-html="stripBB(radical.details.nhnt)"></span>
  </div>
  <div v-if="radical.progress.details" class="radical-meaning">
    <span style="font-weight: bold">Comment: </span>
    <span v-if="radical.progress.details.t">【{{radical.progress.details.t}}】</span>
    <span v-if="radical.progress.details.m" v-html="stripBB(radical.progress.details.m)"></span>
  </div>
</div>
`
});
