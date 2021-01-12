<template>
  <div class="vue-modal">
    <div class="modal-trigger" @click="opened = !opened">
      <slot />
    </div>
    <div v-if="opened" class="modal-mask" @click="opened = false">
      <div class="modal-container">
        <div class="modal-header">
          <slot name="title">{{ title }}</slot>
        </div>
        <div class="modal-body">
          <slot name="content" />
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    title: { type: String, default: null },
  },
  data() {
    return { opened: false }
  },
}
</script>

<style lang="scss" scoped>
.vue-modal {
  display: inline-block;
}
.modal-mask {
  position: fixed;
  z-index: 9998;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.5);
  transition: opacity 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
}

.modal-container {
  min-width: 20em;
  max-width: 90%;
  max-height: 90%;
  margin: 0px auto;
  background: var(--bg);
  border-radius: 2px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.33);
  transition: all 0.3s ease;
  font-family: Helvetica, Arial, sans-serif;
  overflow-y: auto;
}
.modal-header {
  padding: 0.6em 0.8em 0.4em 0.8em;
  background: var(--bg-secondary);
  border-bottom: 1px solid var(--border-color);
}
.modal-body {
  padding: 0.4em 0.8em;
  color: var(--color-secondary);

  ul {
    padding-left: 1em;
  }
}
</style>
