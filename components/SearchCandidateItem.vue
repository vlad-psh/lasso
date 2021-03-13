<template>
  <div
    class="candidate-item no-refocus"
    :class="{ selected: isSelected }"
    @click="onClick(item[0])"
  >
    <div class="title">
      <div class="common-icon" :class="item[4] ? 'common' : 'uncommon'">
        &#x2b50;
      </div>
      <div class="text">{{ item[1] }}</div>
      <div v-if="item[5]" class="learned-icon"><LearnedIcon /></div>
    </div>
    <div class="details">{{ item[2] }}・{{ item[3] }}</div>
  </div>
</template>

<script>
import LearnedIcon from '@/assets/icons/learned.svg?inline'

export default {
  components: { LearnedIcon },
  props: {
    item: { type: Array, required: true },
    isSelected: { type: Boolean },
    onClick: { type: Function, required: true },
  },
}
</script>

<style lang="scss">
.candidate-item {
  padding: 0.2em 0.4em;
  border-bottom: 1px solid var(--border-color);
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
      float: right;

      svg {
        height: 1em;
        width: 1em;
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
