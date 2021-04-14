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
          const activeA = this.activeDrills.includes(a.id)
          const activeB = this.activeDrills.includes(b.id)
          if (activeB) {
            return activeA ? 0 : 1
          } else {
            return activeA ? -1 : b.id - a.id
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
  z-index: 500;
  position: relative;

  .table-wrapper {
    max-height: 20em;
    overflow-y: auto;
    scrollbar-width: thin;
    scrollbar-color: #7775 transparent;
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
        .status .selected {
          background: white;
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
        mask-image: url('assets/icons/checkmark.svg');
        mask-size: 1em 1em;
        background-color: #3173d7;
      }
    }
  }
}
@media (max-width: 568px) {
  .drill-select {
    font-size: 0.8em;

    .table-wrapper {
      scrollbar-width: auto;
    }
  }
}
</style>
