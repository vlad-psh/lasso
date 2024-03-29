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
  },

  hooks: {
    'pages:extend'(pages) {
      pages.push({
        name: 'index',
        redirect: { name: 'search' },
      }, {
        name: 'search',
        path: '/search/:query?/:seq?',
        file: '~/pages/search.vue',
      }, {
        name: 'jiten',
        path: '/jiten/:mode/:query',
        file: '~/pages/jiten.vue',
      }, {
        name: 'quiz',
        path: '/quiz/:drill_id/:type',
        file: '~/pages/quiz.vue',
      })
    },
  },

  colorMode: {
    preference: 'light', // disable system mode
  },
})
