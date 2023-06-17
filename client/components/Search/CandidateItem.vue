<template>
  <div
    class="candidate-item no-refocus"
    :class="{ selected: isSelected }"
    @click="onClick(item[0])"
  >
    <div class="title">
      <div class="text ja">{{ item[1] }}</div>
      <div class="icons">
        <div v-if="item[5]" class="learned-icon"><LearnedIcon /></div>
        <div v-if="item[4]" class="common-icon">&#x2b50;</div>
      </div>
    </div>
    <div class="details">
      <span class="ja">{{ item[2] }}</span
      >・<span class="en">{{ item[3] }}</span>
    </div>
  </div>
</template>

<script setup>
  import LearnedIcon from '../../assets/icons/learned.svg'

  defineProps({
    item: { type: Array, required: true },
    isSelected: { type: Boolean },
    onClick: { type: Function, required: true },
  })
</script>

<style lang="scss">
.candidate-item {
  padding: 0.2em 0.4em;
  cursor: pointer;
  border-radius: 0.2em;
  margin: 0.1em 0.2em;

  &.selected {
    background-image: linear-gradient(to bottom, #1aa0d5, #095bb3);
    color: white;
    padding: 0.4em 0.4em;
  }

  &:hover,
  &.selected {
    .title {
      font-weight: 700;
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
      font-weight: 400;
    }

    .common-icon,
    .learned-icon {
      display: inline-block;
      font-size: 0.8em;

      svg {
        height: 1em;
        width: 1em;
      }
    }
  }
  .details {
    width: 100%;
    font-size: 0.72em;
    opacity: 0.5;
    text-overflow: ellipsis;
    overflow: hidden;
    white-space: nowrap;
  }
}

@media (max-width: 568px) {
  .candidate-item {
    margin: 0;
    border-radius: 0;

    .title {
      font-size: 0.9em;
    }
  }
}
</style>
