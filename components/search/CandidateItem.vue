<template>
  <div
    class="candidate-item no-refocus"
    :class="{ selected: isSelected }"
    @click="openWord(resultIndex)"
  >
    <div class="title">
      <div class="common-icon" :class="result[4] ? 'common' : 'uncommon'">
        &#x2b50;
      </div>
      <div class="text">{{ result[1] }}</div>
      <div v-if="result[5]" class="learned-icon"></div>
    </div>
    <div class="details">{{ result[2] }}・{{ result[3] }}</div>
  </div>
</template>

<script>
export default {
  props: {
    result: { type: Array, required: true },
  },
  computed: {
    isSelected() {
      return this.$store.state.search.selectedSeq === this.result[0]
    },
  },
}
</script>

<style lang="scss">
.candidate-item {
  padding: 0.2em 0.4em;
  border-bottom: 1px solid rgba(192, 192, 192, 0.3);
  cursor: pointer;

  &.selected {
    background: #008ace !important;
    color: white;
  }
  &:hover,
  &.selected {
    .title {
      font-weight: bold;
    }
    .details {
      opacity: 1;
    }
  }
  .title {
    display: flex;
    align-items: center;

    .text {
      flex-grow: 10;
    }

    .common-icon {
      display: inline-block;
      margin-right: 0.2em;
      font-weight: normal;

      &.uncommon {
        opacity: 0;
      }
    }
    .learned-icon {
      font-weight: normal;
      float: right;

      &::after {
        content: '\01f989';
      }
    }
  }
  .details {
    width: 27em;
    padding-left: 1.7em;
    font-size: 0.7em;
    opacity: 0.5;
    text-overflow: ellipsis;
    overflow: hidden;
    white-space: nowrap;
  }
}
</style>
