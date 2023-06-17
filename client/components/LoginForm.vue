<template>
  <div class="middle-content">
    <h2>Login</h2>
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
    display: flex;
    flex-direction: column;
    align-items: center;
    position: relative;

    &.readonly:after {
      content: '';
      display: block;
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background: #ffffff77;
      z-index: 1000;
    }
  }
  input {
    padding: 0.2em 0.5em;
    margin: 0.5em 0;
    border: revert !important;
    background: revert !important;
    color: revert !important;
  }
  .error {
    background: #ff00008f;
    padding: 0.2em 0.6em;
    font-size: 0.9em;
  }
</style>
