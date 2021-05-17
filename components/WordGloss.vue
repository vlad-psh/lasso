<template>
  <div v-if="payload.length > 0" class="word-details center-block">
    <FlagUK v-if="lang === 'uk'" class="svg-icon" />
    <FlagRU v-if="lang === 'ru'" class="svg-icon" />
    <FlagAZ v-if="lang === 'az'" class="svg-icon" />
    <FlagJP v-if="lang === 'jp'" class="svg-icon" />

    <template v-if="lang === 'jp'">
      <DefinitionNode
        v-for="(line, lineIdx) of payload"
        :key="`l${lineIdx}`"
        class="gloss-line"
        node-name="line"
        :children="line"
      >
      </DefinitionNode>
    </template>
    <template v-else>
      <span v-for="(sense, senseIndex) of payload" :key="senseIndex">
        <span v-if="payload.length > 1">{{ bullets[senseIndex] }} </span>
        <span v-if="sense.pos" class="pos"
          >{{ sense.pos.map((i) => i.replace(/^.(.*).$/, '$1')).join(', ') }}
        </span>

        <template v-if="lang !== 'jp'">
          <span>
            {{ sense.gloss.join(', ') }}
          </span>
        </template>
      </span>
    </template>
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
    payload: { type: Array, required: true },
    lang: { type: String, required: true },
    seq: { type: Number, default: null },
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
.definition-node {
  line-height: 1.7em;

  a {
    text-decoration: none;
    color: inherit;
    background: var(--bg-secondary);
    border: 1px solid var(--bg);
  }

  &.gloss-line + &.gloss-line {
    display: block;
    &:before {
      content: '';
      display: inline-block;
      width: 1em;
    }
  }
  &.subscript {
    vertical-align: super;
    color: #ca1717;
    font-size: 0.7em;
    line-height: 0.5em;
  }
  &.decoration {
    font-weight: bold;
    color: #ca1717;
  }
}
</style>
