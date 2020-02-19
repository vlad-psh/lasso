Vue.component('vue-learn-buttons', {
  props: {
    postData: {type: Object, required: true},
    progress: {type: Object, required: true},
    paths:    {type: Object, required: true},
    editing:  {type: Boolean, required: true}
  },
  data() {
    return {
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
    }
  }, // end of methods
  template: `
<div class="vue-learn-buttons">
  {{status}}

  <span v-if="editing && !progress.flagged_at">
    <vue-double-click-button @click="flag()">flag!</vue-double-click-button>
  </span>

  <span v-if="editing && !progress.learned_at && !progress.burned_at">
    <vue-double-click-button @click="learn()">learn!</vue-double-click-button>
  </span>

  <span v-if="editing && progress.learned_at && !progress.burned_at">
    <vue-double-click-button @click="burn()">burn!</vue-double-click-button>
  </span>
</div>
`
});
