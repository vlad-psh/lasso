const axios = require('axios');

Vue.component('vue-toggle-button', {
  props: {
    name: {type: String, required: true},
    value: {type: String, required: true},
    text: {type: String, required: true},
    url: {type: String, required: true},
  },
  data() {
    return {
      v: {name: null, value: null, text: null, url: null},
      disabled: false,
    }
  },
  computed: {
  },
  methods: {
    submit() {
      const app = this;
      const formData = new FormData();
      formData.append(this.name, this.value);
      this.disabled = true;

      axios.patch(this.v.url, formData
      ).then(function(resp) {
        for (let i in resp.data) {
          app.v[i] = resp.data[i];
        }
        app.disabled = false;
      }).catch(function(error) {
        app.disabled = false;
      });
    },
  },
  mounted(){
    this.v.name = this.name;
    this.v.value = this.value;
    this.v.text = this.text;
    this.v.url = this.url;
  },
  template: `
<span class="vue-toggle-button">
  <button @click="submit" :disabled="disabled">{{v.text}}</button>
</span>
`
});
