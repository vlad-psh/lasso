<template>
  <div :class="mode" class="editable-text">
    <template v-if="formOpened">
      <input
        v-if="mode === 'compact'"
        v-model="textCache"
        type="text"
        @keyup.esc="closeForm()"
      />
      <textarea
        v-else
        id="word-comment-textarea"
        v-model="textCache"
        @keyup.esc="closeForm()"
        ref="textarea"
      ></textarea>
      <input type="button" value="Save" @click="updateText()" />
      <div class="error">{{ errorMessage }}</div>
    </template>

    <pre v-else-if="!formOpened && textData" @click="openForm()">{{
      textData
    }}</pre>

    <p v-else @click="openForm()" class="placeholder">
      {{ placeholder }}
    </p>
  </div>
</template>

<script>
export default {
  props: {
    placeholder: { type: String, default: '' },
    textData: { type: String, default: '' },
    mode: { type: String, default: 'large' },
  },
  data() {
    return {
      textCache: null,
      formOpened: false,
      errorMessage: null,
    }
  },
  watch: {
    textData(newText, oldText) {
      this.formOpened = false
      this.textCache = null
    },
  },
  methods: {
    openForm() {
      if (!this.textCache) this.textCache = this.textData
      this.formOpened = true
      this.$nextTick(() => this.$refs.textarea?.focus())
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
      this.textCache = null
    },
  },
}
</script>

<style lang="scss">
.editable-text {
  pre,
  textarea,
  p.placeholder {
    background: #00000006;
    border-radius: 0.4em;
  }

  &:hover {
    cursor: pointer;
  }
  &.compact {
    display: inline-block;

    input[type='text'],
    input[type='button'] {
      font-size: 0.9em;
    }
  } // end of &.compact

  &.large {
    margin: 0.3em 0;
    display: flex;
    align-items: flex-end;
    flex-direction: column;
    justify-content: flex-end;

    textarea {
      height: 8em;
      resize: vertical;
      font-size: inherit;
    }

    textarea,
    pre,
    p.placeholder {
      width: 100%;
      box-sizing: border-box;
      padding: 0.5em 0.8em;
      border: none;
      color: inherit;
    }

    .error {
      float: right;
    }

    input[type='button'] {
      margin-top: 0.5em;
      cursor: pointer;
    }
  } // end of &.large

  pre {
    white-space: pre-wrap;
    font-family: inherit;
    margin: 0;
  }

  p.placeholder {
    margin: 0;
    color: rgba(128, 128, 128, 0.7) !important;
  }

  .error {
    color: #d00;
    font-size: initial;
  }
}
</style>
