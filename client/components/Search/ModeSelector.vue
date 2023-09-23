<template>
  <div class="search-mode">
    <Dropdown trigger="clickToToggle">
      <div class="selected-mode" :class="selectedMode">
        {{ selectedModeTitle }}
      </div>
      <template #popper>
        <div class="popper">
          <div
            v-for="mode in store.searchModes"
            :key="mode.id"
            class="mode-item"
            @click="() => searchModeClick(mode.id)"
          >
            {{ mode.title }}
          </div>
        </div>
      </template>
    </Dropdown>
  </div>
</template>

<script setup>
  import { Dropdown } from 'floating-vue'
  import 'floating-vue/dist/style.css'

  const store = useSearch()

  const props = defineProps({
    selectedMode: { type: String, default: 'search' },
  })

  const emit = defineEmits(['search', 'change'])

  const searchModeClick = (modeId) => {
    emit('change', modeId)
    emit('search')
  }

  const selectedModeTitle = computed(() => {
    return store.searchModes.find(i => i.id === props.selectedMode)?.title
  })
</script>

<style lang="scss" scoped>
.search-mode {
  display: inline-block;

  .selected-mode {
    display: flex;
    align-items: center;
    justify-content: center;

    height: var(--menu-height);
    flex-grow: 100;
    font-size: 0.7em;
    padding: 0 0.5em 0 0.7em;
    white-space: nowrap;

    cursor: pointer;
    color: var(--color);
    background: var(--bg-color);

    &:hover {
      filter: saturate(0.8) brightness(0.8);
    }
  }

  .primary {
    --bg-color: #6c05a5;
    --color: white;
  }
  .kokugo {
    --bg-color: #f5203e;
    --color: white;
  }
  .kanji {
    --bg-color: #66a48e;
    --color: white;
  }
  .onomat {
    --bg-color: #fce35a;
    --color: #665616;
  }

}

.popper .mode-item {
  cursor: pointer;
  padding: 0.4em;
  min-width: 3em;
  text-align: center;

  &:hover {
    background: #008ace;
    color: white;
  }
}
</style>
