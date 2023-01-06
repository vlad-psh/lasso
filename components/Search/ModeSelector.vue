<template>
  <div class="search-mode">
    <div
      v-for="mode of $search.modes"
      :key="`dictmode-${mode.id}`"
      :class="[mode.id, mode.id === selectedMode ? 'selected' : null]"
      @click="searchModeClick(mode.id)"
    >
      {{ mode.title }}
    </div>
  </div>
</template>

<script>
export default {
  props: {
    selectedMode: { type: String, default: null },
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
  display: flex;
  align-items: center;
  justify-content: center;

  & > div {
    min-width: 3.5em;
    padding: 0.2em;
    margin: 0.2em 0.1em;
    border-radius: 0.4em;
    text-align: center;
    font-size: 0.8em;
    cursor: pointer;
    background: var(--background);
    color: var(--color);
    border: 1px solid var(--border-color);

    &:hover,
    &.selected {
      background: var(--bg-secondary);
      color: white;
      font-weight: bold;
      border-color: transparent;

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
  }
}
</style>
