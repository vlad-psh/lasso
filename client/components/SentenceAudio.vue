<template>
  <span class="vue-sentence-audio">
    <audio ref="sentencePlayer" />
    <a class="play-button" @click="playAudio">🔊</a>
  </span>
</template>

<script>
export default {
  props: {
    id: { type: Number, required: true },
  },
  data() {
    return { loaded: false }
  },
  computed: {
    audioUrl() {
      return `/api/sentence/${this.id}/audio`
    },
  },
  mounted() {
    // https://stackoverflow.com/questions/10075909/how-to-set-the-loudness-of-html5-audio
    this.amplifyMedia(this.$refs.sentencePlayer, 2)
  },
  methods: {
    playAudio() {
      if (!this.loaded) {
        this.loaded = true
        this.$refs.sentencePlayer.setAttribute('src', this.audioUrl)
        this.$refs.sentencePlayer.play()
      } else {
        this.$refs.sentencePlayer.currentTime = 0
        this.$refs.sentencePlayer.play()
      }
    },
    amplifyMedia(mediaElem, multiplier) {
      const context = new (window.AudioContext || window.webkitAudioContext)()
      const result = {
        context,
        source: context.createMediaElementSource(mediaElem),
        gain: context.createGain(),
        media: mediaElem,
        amplify(multiplier) {
          result.gain.gain.value = multiplier
        },
        getAmpLevel() {
          return result.gain.gain.value
        },
      }
      result.source.connect(result.gain)
      result.gain.connect(context.destination)
      result.amplify(multiplier)
      return result
    },
  },
}
</script>

<style lang="scss">
.vue-sentence-audio {
  .play-button {
    cursor: pointer;

    &:hover {
      opacity: 0.6;
    }
  }
}
</style>
