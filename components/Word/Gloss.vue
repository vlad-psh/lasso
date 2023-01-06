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
        class="gloss-line ja"
        node-name="line"
        :children="line.items"
      >
      </DefinitionNode>
    </template>
    <template v-else>
      <span v-for="(sense, senseIndex) of payload" :key="senseIndex" class="en">
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
import FlagJP from '@/assets/icons/flag-jp.svg?inline'
import FlagUK from '@/assets/icons/flag-uk.svg?inline'
import FlagRU from '@/assets/icons/flag-ru.svg?inline'
import FlagAZ from '@/assets/icons/flag-az.svg?inline'

export default {
  components: { FlagJP, FlagUK, FlagRU, FlagAZ },
  props: {
    payload: { type: Array, required: true },
    lang: { type: String, required: true },
  },
  data() {
    return {
      bullets:
        '①②③④⑤⑥⑦⑧⑨⑩⑪⑫⑬⑭⑮⑯⑰⑱⑲⑳㉑㉒㉓㉔㉕㉖㉗㉘㉙㉚㉛㉜㉝㉞㉟㊱㊲㊳㊴㊵㊶㊷㊸㊹㊺㊻㊼㊽㊾㊿'.split(
          ''
        ),
    }
  },
}
</script>

<style lang="scss" scoped>
.word-details {
  text-align: justify;
  padding: 0.4em;

  .icon {
    // @include non-selectable;
    display: inline-block;
    font-size: 1.4em;
    vertical-align: middle;
    margin-right: 0.3em;
    line-height: 0;
  }
  .pos {
    color: green;
    font-style: italic;
    font-size: 0.9em;
  }
}
</style>
