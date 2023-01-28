<template>
  <a class="icon" @click="switchValue()">
    <SunIcon v-if="$colorMode.preference === 'light'" />
    <MoonIcon v-else />
  </a>
</template>

<script>
import SunIcon from '@/assets/icons/sun.svg?inline'
import MoonIcon from '@/assets/icons/moon.svg?inline'

export default {
  components: {
    SunIcon,
    MoonIcon,
  },
  methods: {
    switchValue() {
      if (this.$colorMode.preference === 'dark') {
        this.$colorMode.preference = 'light'
      } else {
        this.$colorMode.preference = 'dark'
      }
    },
  },
}
</script>

<style lang="scss"></style>
