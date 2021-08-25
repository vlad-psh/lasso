<template>
  <div class="drill-create-new">
    <input
      v-if="!expanded"
      type="button"
      value="Add new"
      class="expand-button"
      @click="expand"
    />
    <div v-else>
      <input
        ref="inputField"
        v-model="drillName"
        type="text"
        placeholder="Drill name"
        @keydown.esc="expanded = false"
      />
      <input
        type="button"
        value="Create"
        class="submit-button"
        @click="submit"
      />
      <div class="error">{{ error }}</div>
    </div>
  </div>
</template>

<script>
export default {
  data() {
    return {
      expanded: false,
      drillName: '',
      error: null,
    }
  },
  methods: {
    async submit() {
      this.error = null
      try {
        const resp = await this.$axios.post('/api/drills', {
          title: this.drillName,
        })

        this.expanded = false
        this.drillName = ''
        this.$store.commit('cache/ADD_DRILL', resp.data)
      } catch (e) {
        this.error = e.response.data
      }
    },
    expand() {
      this.expanded = true
      this.$nextTick(() => {
        this.$refs.inputField.focus()
      })
    },
  },
}
</script>

<style lang="scss" scoped>
input[type='button'] {
  border: none;
  background: #aaa5;
  color: inherit;
  border-radius: 3px;
  cursor: pointer;
  padding: 0.2em 0.4em;

  &:hover {
    opacity: 0.7;
  }
  &:active {
    transform: translateY(2px);
  }
}

.expand-button {
  width: 15em;
}

.error {
  color: #d00;
}
</style>
