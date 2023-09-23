// Stubbint vue directive to avoid SSR errors
//
// https://nuxt.com/docs/guide/directory-structure/plugins#vue-directives

export default defineNuxtPlugin(nuxtApp => {
  nuxtApp.vueApp.directive('shortkey', {
    mounted () {},
  })
})
