export default {
  // Global page headers (https://go.nuxtjs.dev/config-head)
  head: {
    title: null,
    titleTemplate(title) {
      return title ? `${title} - jisho` : 'jisho'
    },
    meta: [
      { charset: 'utf-8' },
      { name: 'viewport', content: 'width=device-width, initial-scale=1' },
      { hid: 'description', name: 'description', content: '' },
    ],
    link: [{ rel: 'icon', type: 'image/x-icon', href: '/favicon.ico' }],
  },

  // Global CSS (https://go.nuxtjs.dev/config-css)
  css: ['~/assets/main.scss'],

  // Plugins to run before rendering page (https://go.nuxtjs.dev/config-plugins)
  plugins: [
    '@/plugins/vue-shortkey.client.js',
    '@/plugins/preload-search.server.js',
  ],

  // Auto import components (https://go.nuxtjs.dev/config-components)
  components: true,

  // Modules for dev and build (recommended) (https://go.nuxtjs.dev/config-modules)
  buildModules: [
    '@nuxtjs/eslint-module', // https://go.nuxtjs.dev/eslint
    '@nuxtjs/color-mode',
    '@nuxtjs/svg',
  ],

  // Modules (https://go.nuxtjs.dev/config-modules)
  modules: [
    '@nuxtjs/axios', // https://go.nuxtjs.dev/axios
    '@nuxtjs/proxy',
  ],

  // Axios module configuration (https://go.nuxtjs.dev/config-axios)
  axios: {},

  // Build Configuration (https://go.nuxtjs.dev/config-build)
  build: {},

  colorMode: {
    preference: 'light', // disable system
  },

  router: {
    extendRoutes(routes, resolve) {
      routes.push({
        name: 'index',
        path: '/',
        component: 'pages/search.vue',
      })
    },
  },

  proxy: {
    '/api': {
      target: 'http://127.0.0.1:9292/',
      headers: { Connection: 'keep-alive' },
      secure: false,
      changeOrigin: true,
      logLevel: 'debug',
    },
  },

  // Customizing progress bar
  loading: {
    color: '#008ace',
  },
}
