<template>
  <div class="vue-double-click-button no-refocus" :class="state" @click="click">
    <div class="timeout"></div>
    <div class="title"><slot></slot></div>
  </div>
</template>

<script>
export default {
  props: {},
  data() {
    return {
      state: 'default', // default -> waiting -> clicked
    }
  },
  methods: {
    click() {
      if (this.state === 'default') {
        this.state = 'waiting'
        setTimeout(() => {
          this.state = 'default'
        }, 1000)
      } else if (this.state === 'waiting') {
        this.state = 'clicked'
        this.$emit('click')
      }
    },
  },
}
</script>

<style lang="scss">
.vue-double-click-button {
  // @include non-selectable;
  display: inline-block;
  cursor: pointer;
  margin-right: 0.3em;
  border: 1px solid;
  border-radius: 3px;
  user-select: none;

  .title {
    margin: -0.1em 0.4em 0 0.4em;
  }
  .timeout {
    height: 2px;
    background-color: red;
    margin: 0 auto;
    width: 100%;
    opacity: 0;
  }
  &.waiting .timeout {
    transition: width 1s ease-out;
    width: 0;
    opacity: 1;
  }
  &.clicked {
    background-color: #ffec83;
    color: #333;
  }
}
</style>
