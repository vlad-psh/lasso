<template>
  <div id="search-app">
    <div class="browse-panel">
      <div class="search-results">
        <slot name="list" />
      </div>
    </div>
    <div class="contents-panel">
      <slot name="content" />
    </div>
  </div>
</template>

<style lang="scss" scoped>
#search-app {
  .browse-panel {
    position: fixed;
    top: var(--menu-height);
    left: 0;
    height: calc(100% - var(--menu-height));
    width: var(--search-input-width);
    border: 0px solid var(--border-color);
    border-right-width: 1px;
    display: grid;
    grid-template-rows: auto auto 1fr;

    .search-results {
      height: 100%;
      overflow-y: auto;
      overflow-x: hidden;
    }
  }

  .contents-panel {
    margin-left: var(--search-input-width);
  }
}

@media (max-width: 568px) {
  #search-app {
    .browse-panel {
      left: unset;
      right: 0;
      border-right-width: 0;
      border-left-width: 1px;
    }
    .contents-panel {
      margin-left: unset;
      margin-right: var(--search-input-width);
      font-size: 1em;
    }
  }
}
</style>
