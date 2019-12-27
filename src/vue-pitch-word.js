Vue.component('vue-pitch-word', {
  props: {
    word: {type: String, required: true},
    pitch: {type: String, required: false}
  },
  data() {
    return {
      structure: []
    }
  },
  computed: {
    pitchNumber() {
      return this.pitch.replace(/\(.*?\)/g, '');
    }
  },
  methods: {
  },
  mounted(){
    if (this.pitch) {
      var p = Number.parseInt(this.pitch.replace(/\(.*?\)/g, '')[0]);
      var w = this.word;
      var struct = []
      if (p === 0) {
        struct.push([w[0], 'br']); // first mora bottom + right borders
        struct.push([w.substr(1, w.length - 1), 't']); // the rest with top border
      } else if (p === 1) {
        struct.push([w[0], 'tr']);
        struct.push([w.substr(1, w.length - 1), 'b']);
      } else {
        struct.push([w[0], 'br']);
        struct.push([w.substring(1, p), 'tr']);
        struct.push([w.substr(p, w.length - 1), 'b']);
      }
      this.structure = struct;
    }
  },
  template: `
<span class="vue-pitch-word">
  <template v-if="structure.length > 0">
    <span v-for="part of structure" :class="part[1]">{{part[0]}}</span><span class="pitch-number">{{pitchNumber}}</span>
  </template>
  <template v-else>{{word}}</template>
</span>
`
});
