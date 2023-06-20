import Shortkey from 'vue3-shortkey'

export default defineNuxtPlugin(nuxtApp => {
  Shortkey.install(nuxtApp.vueApp, {
    prevent: ['input:not(.shortkey-enabled)', 'textarea:not(.shortkey-enabled)'],
  })
})
