import type { RouterConfig } from '@nuxt/schema'

export default <RouterConfig>{
  routes: (routes) => {
    return [
      {
        name: 'index',
        path: '/',
        redirect: { name: 'search' },
      },
      {
        name: 'search',
        path: '/search',
        component: () => import('~/pages/search.vue'),
      },
      {
        name: 'jiten',
        path: '/jiten/:mode/:query',
        component: () => import('~/pages/jiten.vue'),
      },
      {
        name: 'quiz',
        path: '/quiz/:drill_id/:type',
        component: () => import('~/pages/quiz.vue'),
      },
      ...routes,
    ]
  }
}
