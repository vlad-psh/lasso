<template>
  <div class="similars ja">
    <div
      v-for="(cells, i) of [
        ['jy', 'y'],
        ['j', 'n'],
      ]"
      :key="'similar' + i"
      class="row"
    >
      <div
        v-for="(cell, j) of cells"
        :key="'similar' + i + j"
        :class="cell"
        v-text="payload[cell].join('')"
      ></div>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    payload: { type: Object, required: true },
  },
}
</script>

<style lang="scss">
.similars {
  display: table;

  .row {
    display: table-row;

    div {
      display: table-cell;
      padding: 0.1em 0.5em;

      &:nth-child(1) {
        text-align: right;
        border-right: 1px solid #7775;
      }
    }

    &:nth-child(1) div {
      border-bottom: 1px solid #7775;
    }

    .y:after,
    .j:before {
      font-size: 0.7em;
      color: #d00;
    }
    .y:after {
      content: 'よみ';
    }
    .j:before {
      content: '常用';
    }
  }
}
</style>
