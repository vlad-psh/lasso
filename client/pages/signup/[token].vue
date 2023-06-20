<template>
  <div class="middle-content login-form">
    <h2>Registration</h2>
    <form :class="{ readonly }">
      <input
        v-model="username"
        :readonly="readonly"
        type="text"
        placeholder="Username"
      />

      <input
        v-model="password"
        :readonly="readonly"
        type="password"
        placeholder="Password"
      />
      <input
        v-model="passwordConfirmation"
        :readonly="readonly"
        type="password"
        placeholder="Repeat password"
      />
      <div v-if="passwordMismatch" class="error">
        Password confirmation doesn't match
      </div>
      <div v-if="error" class="error">{{ error }}</div>
      <input
        type="submit"
        value="Sign up"
        :disabled="readonly"
        @click.prevent="submit"
      />
    </form>
  </div>
</template>

<script setup>
  const route = useRoute()

  const username = ref(null)
  const password = ref(null)
  const passwordConfirmation = ref(null)
  const error = ref(null)
  const readonly = ref(false)

  const passwordMismatch = computed(() => {
    const p1 = password.value
    const p2 = passwordConfirmation.value
    return !!(p1 && p2 && p1 !== p2)
  })

  const submit = () => {
    error.value = null
    readonly.value = true

    $fetch('/api/signup', {
      method: 'POST',
      body: {
        token: route.params.token,
        username: username.value,
        password: password.value,
      }
    })
      .then(() => {
        console.log('now should be automatically logged in')
        // this.$auth.login({
        //   username: this.username,
        //   password: this.password,
        // })
      })
      .catch((e) => {
        error.value = e.response.data
      })
      .finally(() => {
        readonly.value = false
      })
  }
</script>
