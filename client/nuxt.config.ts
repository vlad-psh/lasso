// https://nuxt.com/docs/api/configuration/nuxt-config
import svgLoader from "vite-svg-loader"

export default defineNuxtConfig({
  app: {
    head: {
      charset: 'utf-8',
      viewport: 'width=device-width, initial-scale=1',
      title: 'Lasso',
    }
  },

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
    server: {
      allowedHosts: true,
    }
  },

  colorMode: {
    preference: 'light', // disable system mode
  },

})
