// https://nuxt.com/docs/api/configuration/nuxt-config
import svgLoader from "vite-svg-loader"

export default defineNuxtConfig({
  modules: [
    '@nuxtjs/color-mode',
    '@pinia/nuxt',
  ],

  imports: {
    dirs: ['./store'],
  },

  pinia: {
    autoImports: ['defineStore', 'acceptHMRUpdate'],
  },

  vite: {
    plugins: [
      svgLoader(),
    ],
  },

  colorMode: {
    preference: 'light', // disable system mode
  },
})
