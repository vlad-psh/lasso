Vue.component('learn-buttons', {
  props: {
    postData: {type: Object, required: true},
    progress: {type: Object, required: true},
    paths:    {type: Object, required: true},
    editing:  {type: Boolean, required: true}
  },
  data() {
    return {
      drillTitle: null
    }
  },
  computed: {
    status() {
      var s = [];
      if (this.progress.flagged_at) s.push('flagged');
      if (this.progress.learned_at) s.push('learned');
      if (this.progress.burned_at) s.push('burned');
      if (s.length === 0) s.push('new');
      return s.join(', ');
    }
  },
  methods: {
    learn() {
      $.ajax({
        url: this.paths.learn,
        method: "POST",
        data: this.postData
      }).done(data => {
        this.$emit('update-progress', JSON.parse(data));
      });
    },
    burn() {
      $.ajax({
        url: this.paths.burn,
        method: "POST",
        data: this.postData
      }).done(data => {
        this.$emit('update-progress', JSON.parse(data));
      });
    },
    flag() {
      $.ajax({
        url: this.paths.flag,
        method: "POST",
        data: this.postData
      }).done(data => {
        this.$emit('update-progress', JSON.parse(data));
      });
    },
    addToDrill() {
      $.ajax({
        url: this.paths.drill,
        method: "POST",
        data: {drillTitle: this.drillTitle, ...this.postData}
      }).done(data => {
        alert(data);
      });
    }
  }, // end of methods
  template: `
<div class="vue-learn-buttons">
  Status: {{status}}

  <span v-if="editing && !progress.flagged_at">
    <a @click="flag()" class="button">flag!</a>
  </span>

  <span v-if="editing && !progress.learned_at && !progress.burned_at">
    <a @click="learn()" class="button">learn!</a>
  </span>

  <span v-if="editing && progress.learned_at && !progress.burned_at">
    <a @click="burn()" class="button">burn!</a>
  </span>

  <span v-if="editing && postData.kind === 'w'">
    <input type="text" v-model="drillTitle" @keyup.enter="addToDrill()">
  </span>
</div>
`
});
