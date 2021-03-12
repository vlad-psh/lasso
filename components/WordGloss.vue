<template>
  <div v-if="glosses.length > 0" class="word-details center-block">
    <div class="flag-icon">
      <FlagUK v-if="flag === 'uk'" />
      <FlagRU v-if="flag === 'ru'" />
      <FlagAZ v-if="flag === 'az'" />
      <FlagJP v-if="flag === 'jp'" />
    </div>
    <span v-for="(gloss, glossIndex) of glosses" :key="glossIndex">
      <span v-if="glosses.length > 1">{{ bullets[glossIndex] }} </span>
      <span v-if="gloss.pos" class="pos"
        >{{ gloss.pos.map((i) => i.replace(/^.(.*).$/, '$1')).join(', ') }}
      </span>
      <span
        v-for="(line, lineIndex) of gloss.gloss.join(', ').split('\n')"
        :key="'g' + glossIndex + lineIndex"
        class="gloss-line"
      >
        {{ line }}
      </span>
    </span>
  </div>
</template>

<script>
import FlagUK from '@/assets/icons/flag-uk.svg?inline'
import FlagRU from '@/assets/icons/flag-ru.svg?inline'
import FlagAZ from '@/assets/icons/flag-az.svg?inline'
import FlagJP from '@/assets/icons/flag-jp.svg?inline'

export default {
  components: { FlagUK, FlagRU, FlagAZ, FlagJP },
  props: {
    glosses: { type: Array, required: true },
    flag: { type: String, required: true },
  },
  data() {
    return {
      bullets: '①②③④⑤⑥⑦⑧⑨⑩⑪⑫⑬⑭⑮⑯⑰⑱⑲⑳㉑㉒㉓㉔㉕㉖㉗㉘㉙㉚㉛㉜㉝㉞㉟㊱㊲㊳㊴㊵㊶㊷㊸㊹㊺㊻㊼㊽㊾㊿'.split(
        ''
      ),
    }
  },
}
</script>

<style lang="scss">
.flag-icon {
  display: inline-block;
  svg {
    width: 1.5em;
    height: 1.5em;
    vertical-align: bottom;
  }
}
.word-details {
  .gloss-line + .gloss-line {
    &:before {
      content: '';
      display: block;
    }
  }
}
</style>
