<template>
  <div class="contents-panel">
    <!-- <div
        v-else
        class="center-block loading"
        style="margin-top: 1em; margin-bottom: 2em"
      >
        Loading...
      </div>  -->
    <Word
      v-for="seq of $store.state.cache.wordIds"
      :key="seq"
      :seq="seq"
    ></Word>
  </div>
</template>

<style lang="scss" scoped>
.contents-panel {
  height: 100%;
  overflow-y: auto;
}
</style>
