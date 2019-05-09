Vue.component('editable-text', {
  props: {
    postUrl: {type: String, required: true},
    postParams: {type: Object, required: true},
    placeholder: {type: String, required: false},
    textData: {type: String, required: false},
    editing: {type: Boolean, required: true}
  },
  data() {
    return {
      textCache: null,
      formOpened: false
    }
  },
  methods: {
    openForm() {
      if (!this.textCache) this.textCache = this.textData;
      this.formOpened = true;
    },
    closeForm() {
      this.formOpened = false;
    },
    updateText() {
      $.ajax({
        url: this.postUrl,
        data: {comment: this.textCache, ...this.postParams},
        method: "POST"
      }).done(data => {
        this.closeForm();
        this.$emit('updated', this.textCache);
      });
    }
  },
  template: `
<div class="vue-editable-text">
  <template v-if="editing">
    <div v-if="formOpened">
      <textarea id="word-comment-textarea" v-model="textCache" @keyup.esc="closeForm()"></textarea>
      <input type="button" value="Save" @click="updateText()">
    </div>

    <div class="editable-text" @click="openForm()">
      <template v-if="textData">
        <p v-for="commentLine of textData.split('\\n')">{{commentLine}}</p>
      </template>
      <template v-else>
        <p style="font-style: italic; color: rgba(128,128,128,0.7)">{{placeholder}}</p>
      </template>
    </div>
  </template>

  <template v-else-if="textData">
    <div class="word-comment-form center-block">
      <p v-for="commentLine of textData.split('\\n')">{{commentLine}}</p>
    </div>
  </template>
</div>
`
});
