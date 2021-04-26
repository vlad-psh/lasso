<template>
  <div class="editable-text">
    <div v-if="formOpened">
      <textarea
        id="word-comment-textarea"
        v-model="textCache"
        @keyup.esc="closeForm()"
      ></textarea>
      <input type="button" value="Save" @click="updateText()" />
      <div class="error">{{ errorMessage }}</div>
    </div>

    <div v-else @click="openForm()">
      <template v-if="textData">
        <pre>{{ textData }}</pre>
      </template>
      <template v-else>
        <p class="placeholder">
          {{ placeholder }}
        </p>
      </template>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    placeholder: { type: String, default: '' },
    textData: { type: String, default: '' },
  },
  data() {
    return {
      textCache: null,
      formOpened: false,
      errorMessage: null,
    }
  },
  methods: {
    openForm() {
      if (!this.textCache) this.textCache = this.textData
      this.formOpened = true
    },
    closeForm() {
      this.formOpened = false
    },
    updateText() {
      this.errorMessage = null
      const app = this
      this.$emit('save', this.textCache, {
        resolve() {
          app.closeForm()
        },
        reject(msg) {
          app.errorMessage = msg
        },
      })
    },
  },
}
</script>

<style lang="scss">
.editable-text {
  padding: 0.3em 0.6em;
  margin: 0.3em 0;

  &:hover {
    background-color: rgba(128, 128, 128, 0.2);
    cursor: pointer;
  }
  pre {
    white-space: pre-wrap;
    font-family: inherit;
    margin: 0;
    border-left: 3px solid #17a0ca;
    padding-left: 0.5em;
  }
  p.placeholder {
    margin: 0;
    padding-left: 0.5em;
    font-style: italic;
    color: rgba(128, 128, 128, 0.7);
    border-left: 3px solid #7774;
  }
  textarea {
    width: 100%;
    height: 8em;
    resize: vertical;
    font-family: inherit;
    font-size: inherit;
  }
  .error {
    float: right;
    color: #d00;
  }
}
</style>
