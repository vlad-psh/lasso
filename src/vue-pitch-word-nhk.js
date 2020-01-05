Vue.component('vue-pitch-word-nhk', {
  props: {
    j: {type: Object, required: true},
  },
  data() {
    return {
      words: []
    }
  },
  computed: {
  },
  methods: {
  },
  mounted(){
    for (w of Object.keys(this.j)) {
      var word = [];
      for (c of w.split('')) {
        if (c === '@') {
          word[word.length - 1].cl.push('voiceless');
        } else if (c === '~') {
          word[word.length - 1].cl.push('nasal');
        } else if (c === '=') {
          word[word.length - 1].cl.push('t');
        } else if (c === '^') {
          word[word.length - 1].cl.push('tr');
        } else {
          word.push({ch: c, cl: []});
        }
      }
      this.words.push(word);
    }
  },
  template: `
<span class="vue-pitch-word">
  <span v-for="word of words" class="word">
    <span v-for="char of word" :class="char['cl']">{{char['ch']}}</span>
  </span>
</span>
`
});
