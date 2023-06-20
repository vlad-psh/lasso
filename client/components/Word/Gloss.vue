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

<script setup>
  import FlagJP from '../../assets/icons/flag-jp.svg'
  import FlagUK from '../../assets/icons/flag-uk.svg'
  import FlagRU from '../../assets/icons/flag-ru.svg'
  import FlagAZ from '../../assets/icons/flag-az.svg'

  defineProps({
    payload: { type: Array, required: true },
    lang: { type: String, required: true },
  })

  const bullets = '①②③④⑤⑥⑦⑧⑨⑩⑪⑫⑬⑭⑮⑯⑰⑱⑲⑳㉑㉒㉓㉔㉕㉖㉗㉘㉙㉚㉛㉜㉝㉞㉟㊱㊲㊳㊴㊵㊶㊷㊸㊹㊺㊻㊼㊽㊾㊿'.split('')
</script>

<style lang="scss" scoped>
.word-details {
  text-align: justify;
  padding: 0.4em;

  .svg-icon {
    // @include non-selectable;
    margin-right: 0.3em;
  }
  .pos {
    color: green;
    font-style: italic;
    font-size: 0.9em;
    margin-right: 0.3em;
  }
}
</style>
