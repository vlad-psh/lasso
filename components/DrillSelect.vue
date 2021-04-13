<template>
  <div class="drill-select">
    <div class="drills-list">
      <div v-for="drill of drills" :key="drill.id" class="drill-item">
        <div class="margin"></div>
        <div class="title">{{ drill.title }}</div>
        <div class="selected">
          {{ activeDrills.includes(drill.id) ? '✅' : '' }}
        </div>
        <div class="margin"></div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    activeDrills: { type: Array, required: true },
  },
  computed: {
    drills() {
      return (this.$store.state.cache.drills || [])
        .filter((a) => a.is_active || this.activeDrills.includes(a.id))
        .sort((a, b) => {
          if (this.activeDrills.includes(b.id)) {
            return this.activeDrills.includes(a.id) ? 0 : 1
          } else {
            return b.id - a.id
          }
        })
    },
  },
  mounted() {
    // TODO: Improve: One word can have multiple krebs and 'drill select' components
    // But we should get drills list only once. Right now we have simple protetion
    // condition in store/cache. Think how possibly we can improve it.
    this.$store.dispatch('cache/loadDrills')
  },
}
</script>

<style lang="scss">
.drill-select {
  .drills-list {
    max-height: 20em;
    overflow-y: auto;
    text-align: left;
    display: table;
    border-collapse: collapse;

    .drill-item {
      margin: 0.4em 0;
      cursor: pointer;
      display: table-row;

      & > div {
        display: table-cell;
      }
      &:hover {
        background: #87d9f9;
        .title,
        .selected {
          border-color: transparent;
        }
      }
      .margin {
        width: 1em;
      }
      .title {
        white-space: nowrap;
        line-height: 2.5em;
      }
      .selected {
        padding-left: 0.5em;
      }
      .title,
      .selected {
        border-style: solid none none none;
        border-width: 1px;
        border-color: #7775;
      }
      &:first-child {
        .title,
        .selected {
          border-color: transparent;
        }
      }
    }
  }
}
</style>
