<template>
  <div class="middle-content">
    <form>
      <input v-model="username" type="text" placeholder="Username" />
      <input v-model="password" type="password" placeholder="Password" />
      <input type="submit" value="Login" @click.prevent="submit" />
    </form>
  </div>
</template>

<script setup>
  import { ref } from 'vue'

  const { setUser } = useEnv()

  const username = ref('');
  const password = ref('');

  const submit = async () => {
    const resp = await $fetch('/api/session', {
      method: 'POST',
      body: {
        username: username.value,
        password: password.value,
      }
    })
    setUser(JSON.parse(resp))
  }
</script>

<style lang="scss" scoped>
form {
  margin-top: 10em;
}
</style>
