<template>
  <div class="jiten-navigation">
    <div class="hint" @click="leftPage">Shift + ←</div>
    <input
      class="shortkey-enabled"
      v-model="page"
      @keydown.enter="commitPageChange"
      v-shortkey="{
        rightPage: ['shift', 'arrowright'],
        leftPage: ['shift', 'arrowleft'],
      }"
      @shortkey="changePage"
      placeholder="..."
      type="text"
    />
    <div class="hint" @click="rightPage">Shift + →</div>
  </div>
</template>

<script setup>
  const search = useSearch()
  const page = ref(search.current.page)

  const commitPageChange = () => {
    search.updateCurrent({ page: page.value })
  }

  const leftPage = () => {
    page.value = page.value + 1
    commitPageChange()
  }

  const rightPage = () => {
    page.value = page.value - 1
    commitPageChange()
  }

  const changePage = (event) => {
    // Currently we only have books with reverse page order, so 'left' is the 'next page'
    if (event.srcKey === 'leftPage') {
      leftPage()
    } else if (event.srcKey === 'rightPage') {
      rightPage()
    }
  }
</script>

<style lang="scss" scoped>
.jiten-navigation {
  width: var(--search-input-width);
  display: flex;
  justify-content: space-around;
  align-items: center;
  background: var(--bg-secondary);
  padding: 0.3em 0;
  position: fixed;
  top: var(--menu-height);
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
    right: 0;
  }
  input {
    max-width: 2.5em;
  }
}
</style>
