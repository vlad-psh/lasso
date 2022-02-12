<template>
  <div id="__layout_inner">
    <template v-if="$auth.loggedIn === true">
      <MainMenu />
      <Nuxt keep-alive />
    </template>
    <LoginForm v-else-if="$auth.loggedIn === false" />
  </div>
</template>

<script>
export default {}
</script>
