<template>
  <div class="middle-content login-form">
    <h2>Login</h2>
    <form>
      <input v-model="username" type="text" placeholder="Username" />
      <br />
      <input v-model="password" type="password" placeholder="Password" />
      <br />
      <input type="submit" value="Login" @click.prevent="submit" />
    </form>
  </div>
</template>

<script>
export default {
  data() {
    return {
      username: null,
      password: null,
    }
  },
  methods: {
    submit() {
      this.$auth.login({
        username: this.username,
        password: this.password,
      })
    },
  },
}
</script>

<style lang="scss">
.login-form {
  input {
    padding: 0.2em 0.5em;
    margin: 0.5em 0;
    border: revert !important;
    background: revert !important;
    color: revert !important;
  }
}
</style>
