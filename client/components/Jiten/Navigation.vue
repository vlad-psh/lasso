<template>
  <div class="jiten-navigation">
    <div class="hint" @click="prevPage" role="button">
      <span class="hotkey">↑</span>
    </div>
    <input
      class="shortkey-enabled"
      v-model="page"
      @keydown.enter="commitPageChange"
      v-shortkey="{
        prevPage: ['arrowup'],
        nextPage: ['arrowdown'],
      }"
      @shortkey="changePage"
      placeholder="..."
      type="text"
    />
    <div class="hint" @click="nextPage" role="button">
      <span class="hotkey">↓</span>
    </div>
  </div>
</template>

<script setup>
  const search = useSearch()
  const page = ref(search.current.page)

  const commitPageChange = () => {
    search.updateCurrent({ page: page.value })
  }

  const nextPage = () => {
    page.value = page.value + 1
    commitPageChange()
  }

  const prevPage = () => {
    page.value = page.value - 1
    commitPageChange()
  }

  const changePage = (event) => {
    if (event.srcKey === 'prevPage') {
      prevPage()
    } else if (event.srcKey === 'nextPage') {
      nextPage()
    }
  }
</script>

<style lang="scss" scoped>
.jiten-navigation {
  display: flex;
  justify-content: space-around;
  align-items: center;
  --gap: 1.5em;
  padding: 0.3em var(--gap);
  gap: var(--gap);
}

input {
  background: var(--bg) !important;
  border-radius: 1em;
  max-width: 3.5em;
  border: none;
  text-align: center;
  opacity: 0.8;
}

.hint {
  display: inline-block;
  font-size: 0.7em;
  opacity: 0.5;
  font-style: italic;
  cursor: pointer;
  user-select: none;

  &:hover {
    opacity: 0.7;
  }
}

@media (max-width: 568px) {
  .jiten-navigation {
    --gap: 0.6em;
  }
  input {
    max-width: 2.5em;
  }
  .hotkey {
    display: none;
  }
}
</style>
