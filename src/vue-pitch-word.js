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
      var digraphs = 'ゃゅょャュョ'.split('');
      var p = Number.parseInt(this.pitch.replace(/\(.*?\)/g, '')[0]);

      var w = [];
      // split by moras
      for (letter of this.word.split('')) {
        if (digraphs.indexOf(letter) !== -1) {
          w[w.length - 1] = w[w.length - 1] + letter;
        } else {
          w.push(letter);
        }
      }

      var struct = []
      if (p === 0) {
        struct.push([w[0], 'br']); // first mora bottom + right borders
        struct.push([w.slice(1, w.length).join(''), 't']); // the rest with top border
      } else if (p === 1) {
        struct.push([w[0], 'tr']);
        struct.push([w.slice(1, w.length).join(''), 'b']);
      } else {
        struct.push([w[0], 'br']);
        struct.push([w.slice(1, p).join(''), 'tr']);
        struct.push([w.slice(p, w.length).join(''), 'b']);
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
