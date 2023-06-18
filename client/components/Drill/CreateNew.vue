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

<script setup>
  const cache = useCache()

  const expanded = ref(false)
  const drillName = ref('')
  const error = ref(null)
  const inputField = ref()

  const submit = async () => {
    error.value = null
    try {
      const resp = await $fetch('/api/drills', {
        method: 'POST',
        body: {
          title: drillName.value,
        },
      })
      const json = JSON.parse(resp)

      expanded.value = false
      drillName.value = ''
      cache.addDrill(json)
    } catch (e) {
      error.value = e
    }
  }

  const expand = () => {
    expanded.value = true
    nextTick(() => {
      inputField.value.focus()
    })
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
