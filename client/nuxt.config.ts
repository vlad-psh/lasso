// https://nuxt.com/docs/api/configuration/nuxt-config
import svgLoader from "vite-svg-loader"

export default defineNuxtConfig({
  modules: [
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
  }
})
