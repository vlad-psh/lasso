<template>
  <div
    class="candidate-item no-refocus"
    :class="{ selected: isSelected }"
    @click="onClick(item[0])"
  >
    <div class="title">
      <div class="text">{{ item[1] }}</div>
      <div v-if="item[4]" class="common-icon">&#x2b50;</div>
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
  cursor: pointer;
  border-radius: 0.5em;
  margin: 0.1em 0.2em;

  &.selected {
    background-image: linear-gradient(to bottom, #1aa0d5, #095bb3);
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
    gap: 0.3em;

    .text {
      flex-grow: 10;
    }

    .common-icon,
    .learned-icon {
      display: inline-block;

      svg {
        height: 1em;
        width: 1em;
      }
    }
  }
  .details {
    width: 100%;
    font-size: 0.7em;
    opacity: 0.5;
    text-overflow: ellipsis;
    overflow: hidden;
    white-space: nowrap;
  }
}

@media (max-width: 568px) {
  .candidate-item {
    padding: 0.12em 0.2em;
    .title {
      font-size: 0.9em;
      .common-icon,
      .learned-icon {
        font-size: 0.7em;
      }
    }
    .details {
      width: 14em;
      padding-left: 0;
      font-size: 0.7em;
    }
  }
}
</style>
