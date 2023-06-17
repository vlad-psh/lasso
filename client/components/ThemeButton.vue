<template>
  <a class="icon" @click="switchValue()">
    <SunIcon v-if="colorMode === 'light'" />
    <MoonIcon v-else />
  </a>
</template>

<script setup>
  import SunIcon from '../assets/icons/sun.svg'
  import MoonIcon from '../assets/icons/moon.svg'

  const colorMode = useColorMode()

  const switchValue = () => {
    colorMode.preference = colorMode.preference === 'dark' ? 'light' : 'dark'
  }
</script>

<style lang="scss"></style>
