const axios = require('axios');

Vue.component('vue-settings-button', {
  props: {
    name: {type: String, required: true},
    options: {type: Object, required: true},
    value: {type: String, required: true},
  },
  data() {
    return {
      inProgress: false,
      currentValue: null
    }
  },
  computed: {
  },
  methods: {
    nextValue() {
      if (this.inProgress) return;

      const app = this;
      const formData = new FormData();
      const keys = Object.keys(this.options);
      var i = keys.indexOf(this.currentValue) + 1;
      if (i == keys.length) i = 0;
      const newValue = keys[i];
      formData.append(this.name, newValue);

      this.inProgress = true;
      axios.post('/settings', formData
      ).then(function(resp) {
        app.updateValue(newValue);
      }).catch(function(error) {
        app.inProgress = false;
      });
    },
    updateValue(newValue) {
      this.currentValue = newValue;
      this.inProgress = false;

      if (this.name == 'theme') {
        document.querySelector('body').setAttribute('theme', newValue);
      }
    }
  },
  mounted(){
    this.currentValue = this.value;
  },
  template: `
<div class="vue-settings-button" :class="inProgress ? 'in-progress' : null" @click="nextValue()">
  <div class="svg-icon" :class="options[currentValue]"></div>
</div>
`
});
