<template>
  <div :class="mode" class="editable-text">
    <div v-if="formOpened">
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
  &:hover {
    background-color: rgba(128, 128, 128, 0.2);
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
    padding: 0.3em 0.12em;
    margin: 0.3em 0;

    textarea {
      width: 100%;
      height: 8em;
      resize: vertical;
      font-size: 0.9em;
      box-sizing: border-box;
    }

    pre {
      border-left: 3px solid #17a0ca;
      padding-left: 0.5em;
    }

    p.placeholder {
      border-left: 3px solid #7774;
      padding-left: 0.5em;
    }

    .error {
      float: right;
    }
  } // end of &.large

  pre {
    white-space: pre-wrap;
    font-family: inherit;
    margin: 0;
  }

  p.placeholder {
    margin: 0;
    font-style: italic;
    color: rgba(128, 128, 128, 0.7);
  }

  .error {
    color: #d00;
    font-size: initial;
  }
}
</style>
