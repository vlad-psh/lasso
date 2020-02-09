const axios = require('axios');

Vue.component('vue-settings-button', {
  props: {
    name: {type: String, required: true},
    value: {type: String, required: true},
  },
  data() {
    return {
      options: {
        theme: {white: 'icon-sun', black: 'icon-moon'},
        device: {pc: 'icon-pc', mobile: 'icon-mobile'},
      },
      inProgress: false,
      currentValue: null
    }
  },
  computed: {
  },
  methods: {
    switchValue() {
      if (this.inProgress) return;

      const newValue = this.nextValue();
      const formData = new FormData();
      formData.append(this.name, newValue);

      this.currentValue = newValue;
      if (this.name == 'theme') {
        document.querySelector('body').setAttribute('theme', newValue);
      } else if (this.name == 'device') {
        _sDevice = newValue;
      }
      this.saveSettings(formData, () => true);
    },
    nextValue() {
      const keys = Object.keys(this.options[this.name]);
      var i = keys.indexOf(this.currentValue) + 1;
      if (i == keys.length) i = 0;
      return keys[i];
    },
    saveSettings(formData, callback) {
      const app = this;
      app.inProgress = true;
      axios.post('/settings', formData
      ).then(function(resp) {
        app.inProgress = false;
        callback();
      }).catch(function(error) {
        app.inProgress = false;
      });
    },
  },
  mounted(){
    this.currentValue = this.value;
  },
  template: `
<div class="vue-settings-button no-refocus" :class="inProgress ? 'in-progress' : null" @click="switchValue()">
  <div class="svg-icon" :class="options[name][currentValue]"></div>
</div>
`
});
