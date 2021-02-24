<template>
  <div>
    <h2>Login</h2>
    <form>
      <input v-model="username" type="text" placeholder="Username" />
      <input v-model="password" type="password" placeholder="Password" />
      <input type="submit" value="Login" @click.prevent="submit" />
    </form>
  </div>
</template>

<script>
export default {
  middleware({ $auth, redirect }) {
    if ($auth.loggedIn()) redirect('/')
  },
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
