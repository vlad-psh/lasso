<template>
  <div class="search-mode" :class="selectedMode">
    {{ modeLabel }}
  </div>
</template>

<script>
export default {
  props: {
    selectedMode: { type: String, default: null },
  },
  computed: {
    modeLabel() {
      return this.$search.modes.find((i) => i.id === this.selectedMode).title
    },
  },
  methods: {
    searchModeClick(modeId) {
      if (this.selectedMode === modeId) this.$emit('search')
      else this.$emit('change', modeId)
    },
  },
}
</script>

<style lang="scss" scoped>
.search-mode {
  display: inline-block;
  position: absolute;
  padding: 0.44em 0.3em;
  border-radius: 0.5em;
  border-top-right-radius: 0;
  border-bottom-right-radius: 0;
  text-align: center;
  font-size: 0.8em;
  cursor: pointer;
  color: white;
  font-weight: bold;
  background: black;

  &.primary {
    background: #6c05a5;
  }
  &.kokugo {
    background: #f5203e;
  }
  &.kanji {
    background: #66a48e;
  }
  &.onomat {
    background: #fce35a;
    color: #665616;
  }
}
</style>
