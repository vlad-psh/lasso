<template>
  <div class="drill-select">
    <div class="table-wrapper">
      <div class="table">
        <div v-for="drill of drills" :key="drill.id" class="item">
          <div class="margin"></div>
          <div class="title">{{ drill.title }}</div>
          <div class="status">
            <div v-if="activeDrills.includes(drill.id)" class="selected"></div>
          </div>
          <div class="margin"></div>
        </div>
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
  border-radius: 0.5em;
  overflow: hidden;

  .table-wrapper {
    max-height: 20em;
    overflow-y: auto;
    scrollbar-width: thin;
  }
  .table {
    text-align: left;
    display: table;
    border-collapse: collapse;

    .item {
      margin: 0.4em 0;
      cursor: pointer;
      display: table-row;

      & > div {
        display: table-cell;
      }
      &:hover {
        background: #008ace;
        color: white;
        .title,
        .status {
          border-color: transparent;
        }
      }
      .margin {
        width: 1em;
      }
      .title {
        white-space: nowrap;
        line-height: 2.5em;
        padding-right: 0.5em;
      }
      .title,
      .status {
        border-style: solid none none none;
        border-width: 1px;
        border-color: #7773;
      }
      &:first-child {
        .title,
        .status {
          border-top: none;
        }
      }
      .status .selected {
        width: 1em;
        height: 0.9em;
        background: url('assets/icons/checkmark.svg') no-repeat;
        background-size: 1em 1em;
      }
    }
  }
}
@media (max-width: 568px) {
  .drill-select {
    font-size: 0.8em;
  }
}
</style>
