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

<script>
export default {
  data() {
    return {
      username: null,
      password: null,
      passwordConfirmation: null,
      error: null,
      readonly: false,
    }
  },
  computed: {
    passwordMismatch() {
      const p1 = this.password
      const p2 = this.passwordConfirmation
      return !!(p1 && p2 && p1 !== p2)
    },
  },
  methods: {
    submit() {
      this.error = null
      this.readonly = true

      this.$axios
        .post('/api/signup', {
          token: this.$route.params.token,
          username: this.username,
          password: this.password,
        })
        .then(() => {
          this.$auth.login({
            username: this.username,
            password: this.password,
          })
        })
        .catch((e) => {
          this.error = e.response.data
        })
        .finally(() => {
          this.readonly = false
        })
    },
  },
}
</script>
