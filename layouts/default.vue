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
import MainMenu from '@/components/MainMenu'
import LoginForm from '@/components/LoginForm'

export default {
  components: { MainMenu, LoginForm },
}
</script>
