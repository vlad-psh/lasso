<template>
  <div
    class="word-kreb no-refocus"
    :class="[
      kreb.is_common ? 'common' : null,
      kreb.progress.learned_at ? 'learned' : null,
    ]"
  >
    <span class="vue-pitch-word">
      <template v-if="structure.length > 0">
        <span v-for="(part, idx) of structure" :key="idx" :class="part[1]">{{
          part[0]
        }}</span
        ><span class="pitch-number">{{ pitchNumber }}</span>
      </template>
      <template v-else>{{ kreb.title }}</template>
    </span>
  </div>
</template>

<script>
export default {
  props: {
    kreb: { type: Object, required: true },
  },
  data() {
    return {}
  },
  computed: {
    pitch() {
      return this.kreb.pitch || ''
    },
    pitchNumber() {
      return this.pitch.replace(/\(.*?\)/g, '')
    },
    structure() {
      if (this.pitch) {
        const digraphs = 'ゃゅょャュョ'.split('')
        const p = Number.parseInt(this.pitch.replace(/\(.*?\)/g, '')[0])

        const w = []
        // split by moras
        for (const letter of this.kreb.title.split('')) {
          if (digraphs.includes(letter)) {
            w[w.length - 1] = w[w.length - 1] + letter
          } else {
            w.push(letter)
          }
        }

        const struct = []
        if (p === 0) {
          struct.push([w[0], 'br']) // first mora bottom + right borders
          struct.push([w.slice(1, w.length).join(''), 't']) // the rest with top border
        } else if (p === 1) {
          struct.push([w[0], 'tr'])
          struct.push([w.slice(1, w.length).join(''), 'b'])
        } else {
          struct.push([w[0], 'br'])
          struct.push([w.slice(1, p).join(''), 'tr'])
          struct.push([w.slice(p, w.length).join(''), 'b'])
        }
        return struct
      }
      return []
    },
  },
}
</script>

<style lang="scss">
// TODO: this class is also used in WordInfoPitchNhk component
.vue-pitch-word {
  $pitch-color: #d00;
  .br {
    border-bottom: 1px solid $pitch-color;
    border-right: 1px solid $pitch-color;
    margin-right: -1px;
  }
  .tr {
    border-top: 1px solid $pitch-color;
    border-right: 1px solid $pitch-color;
    margin-right: -1px;
  }
  .t {
    border-top: 1px solid $pitch-color;
  }
  .b {
    border-bottom: 1px solid $pitch-color;
  }
  .voiceless::after {
    position: absolute;
    content: '';
    border: 1px dotted #d00;
    border-radius: 1em;
    top: 0;
    left: 0;
    height: 1em;
    width: 1em;
  }
  .nasal::after {
    display: inline-block;
    content: '';
    vertical-align: top;
    width: 0.4em;
    height: 0.4em;
    margin-left: -0.3em;
    margin-top: 0.2em;
    background: white;
    border-radius: 1em;
    border: 1px solid #d00;
    box-sizing: border-box;
  }
  .word {
    margin: 0 0.5em;
    span {
      position: relative; // needed for .voiceless
      padding: 0 0.1em;
    }
  }
  .pitch-number {
    font-size: 0.6em;
    vertical-align: super;
    color: #d00;
    opacity: 0.7;
  }
}
</style>
