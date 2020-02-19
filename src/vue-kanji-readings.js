const axios = require('axios');

Vue.component('vue-kanji-readings', {
  props: {
    kanji: {type: Object, required: true}
  },
  data() {
    return {
      readings: {},
      readingsFetched: false
    }
  },
  computed: {
  },
  methods: {
    fetchReadings() {
      const app = this;
      const formData = new FormData();
      formData.append('kanji', this.kanji.title);

      axios.post('/api/kanji_readings', formData
      ).then(function(resp) {
        app.readingsFetched = true;
        app.readings = resp.data;
      })
    }
  },
  template: `
<div class="vue-kanji-readings">
  <div v-if="kanji.on"><div class="on-label">音</div>{{ kanji.on.join(" · ") }}</div>
  <div v-if="kanji.kun"><div class="kun-label">訓</div><span v-for="kun of kanji.kun" class="reading">{{kun.split('.')[0]}}<span class="okurigana" v-if="kun.split('.').length > 1">{{kun.split('.')[1]}}</span></span></div>
  <div v-if="kanji.nanori">名：{{ kanji.nanori.join(" · ") }}</div>
  <div v-if="readingsFetched">
    <table>
      <tr v-for="reading of Object.keys(readings)">
        <td>{{reading}}</td>
        <td><template v-for="k in readings[reading]">{{k[0]}}</template></td>
      </tr>
    </table>
  </div>
  <div v-else>
    <a @click="fetchReadings()" class="no-refocus">Readings table</a>
  </div>
</div>
`
});
