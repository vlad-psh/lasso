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

  hooks: {
    'pages:extend'(pages) {
      pages.push({
        name: 'index',
        path: '/',
        file: '~/pages/search.vue',
      }, {
        name: 'sub-search',
        path: '/search/:query/:seq?',
        file: '~/pages/search.vue',
      }, {
        name: 'jiten',
        path: '/jiten/:mode/:query',
        file: '~/pages/search.vue',
      }, {
        name: 'sub-quiz',
        path: '/quiz/:drill_id/:type',
        file: '~/pages/quiz.vue',
      })
    },
  },

  colorMode: {
    preference: 'light', // disable system mode
  },
})
