<template>
  <div v-if="glosses.length > 0" class="word-details center-block">
    <div class="icon">{{ flag }}</div>
    <span v-for="(gloss, glossIndex) of glosses" :key="glossIndex">
      <span v-if="glosses.length > 1">{{ bullets[glossIndex] }} </span>
      <span v-if="gloss.pos" class="pos"
        >{{ gloss.pos.map((i) => i.replace(/^.(.*).$/, '$1')).join(', ') }}
      </span>
      {{ gloss.gloss.join(', ') }}
    </span>
  </div>
</template>

<script>
export default {
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
