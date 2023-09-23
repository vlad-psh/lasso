<template>
  <div class="search-mode">
    <div
      v-for="mode in store.searchModes"
      :key="mode.id"
      :class="[mode.id, selectedMode === mode.id ? 'active' : null]"
      @click="() => searchModeClick(mode.id)"
    >
      {{ mode.title }}
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
  padding: 0.1em 0;
  background: var(--menu-bg-color);

  div {
    display: flex;
    align-items: center;
    justify-content: center;

    height: calc(var(--menu-height) - 0.4em);
    flex-grow: 100;
    font-size: 0.9em;
    min-width: 5em;
    margin: 0.1em;

    cursor: pointer;
    --color: white;
    border: 1px solid var(--bg-color);
    border-radius: 0.3em;
    color: var(--color);
    background: var(--bg-color);
    filter: saturate(0.5) brightness(0.5);

    &:hover, &.active {
      filter: none;
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
