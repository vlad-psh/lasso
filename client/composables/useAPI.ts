import type { UseFetchOptions } from 'nuxt/app'

export function useAPI<T>(
  url: string | (() => string),
  options?: UseFetchOptions<T>,
) {
  const baseURL = useRequestURL().origin
  const headers = useRequestHeaders(['cookie'])

  return useFetch(url, {
    baseURL,
    headers,
    ...options,
    $fetch: useNuxtApp().$apiRequest as typeof $fetch
  })
}
