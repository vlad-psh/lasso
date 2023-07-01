<template>
  <div class="search-mode">
    <div
      v-for="mode in store.searchModes"
      :key="mode.id"
      :class="[mode.id, selectedMode === mode.id ? 'active' : null]"
      @click="() => searchModeClick(mode.id)"
    >
      <span>{{ mode.title }}</span>
    </div>
  </div>
</template>

<script setup>
  const store = useSearch()

  const props = defineProps({
    selectedMode: { type: String, default: null },
  })

  const emit = defineEmits(['search', 'change'])

  const searchModeClick = (modeId) => {
    if (props.selectedMode === modeId) emit('search')
    else emit('change', modeId)
  }
</script>

<style lang="scss" scoped>
.search-mode {
  display: flex;
  justify-content: center;
  flex-wrap: wrap;
  gap: 0.1em;
  padding: 0.1em;

  div {
    flex-grow: 100;
    font-size: 0.9em;
    min-width: 5em;
    padding: 0.1em 0 0.2em;
    text-align: center;
    cursor: pointer;
    --color: white;
    border: 1px solid var(--bg-color);

    span {
      padding: 0.2em 0.3em 0.1em;
    }

    &:hover, &.active {
      background: var(--bg-color);
      color: var(--color);
    }
  }

  .primary {
    --bg-color: #6c05a5;
  }
  .kokugo {
    --bg-color: #f5203e;
  }
  .kanji {
    --bg-color: #66a48e;
  }
  .onomat {
    --bg-color: #fce35a;
    --color: #665616;
  }
}
</style>
