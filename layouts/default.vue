<template>
  <div id="__layout_inner">
    <MainMenu />
    <Nuxt keep-alive :keep-alive-props="{ include: 'search' }" />
  </div>
</template>

<script>
export default {}
</script>
