<template>
  <div class="contents-panel">
    <div v-for="w of $store.state.search.words" :key="w.seq">
      <vue-word
        v-if="w.data"
        :key="w.seq"
        :seq="w.seq"
        :j="w.data"
        :editing="true"
        @search="searchExec"
      ></vue-word>
      <div
        v-else
        class="center-block loading"
        style="margin-top: 1em; margin-bottom: 2em"
      >
        Loading...
      </div>
      <div class="tear-line" />
    </div>
  </div>
</template>

<style lang="scss" scoped>
.contents-panel {
  height: 100%;
  overflow-y: auto;

  .vue-word {
    &.highlighted {
      animation: 2s ease-out 0s 1 normal blink-highlight;
    }
  }

  .tear-line {
    width: 100%;
    height: 16px;
    background-repeat: repeat-x;
    background-size: 10px 16px;
  }
}
</style>
