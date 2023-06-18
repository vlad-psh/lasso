<template>
  <div class="search-mode" :class="selectedMode">
    {{ modeLabel }}
  </div>
</template>

<script setup>
  const store = useSearch()

  const props = defineProps({
    selectedMode: { type: String, default: null },
  })

  const emit = defineEmits(['search', 'change'])

  const modeLabel = computed(() => {
    return store.searchModes.find((i) => i.id === props.selectedMode).title
  })

  const searchModeClick = (modeId) => {
    if (props.selectedMode === modeId) emit('search')
    else emit('change', modeId)
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
