Vue.component('vue-sentence-audio', {
  props: {
    id: {type: Number, required: true},
  },
  data() {
    return {
      loaded: false,
    }
  },
  computed: {
    audioUrl() {
      return `/api/sentence/${this.id}/audio`;
    },
  },
  methods: {
    loadAudio() {
      this.loaded = true;
      this.$refs.sentencePlayer.setAttribute('src', this.audioUrl);
      this.$refs.sentencePlayer.play();
    },
    replayAudio() {
      this.$refs.sentencePlayer.currentTime = 0;
      this.$refs.sentencePlayer.play();
    },
  },
  mounted(){
  },
  template: `
<span class="vue-sentence-audio">
  <audio ref="sentencePlayer"/>
  <input v-if="!loaded" type="button" value="Listen" @click="loadAudio">
  <input v-else type="button" value="Listen" @click="replayAudio">
</span>
`
});
