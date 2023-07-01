export const useOriginFetch = (url, props) => {
  const baseURL = useRequestURL().origin
  const headers = useRequestHeaders(['cookie'])

  return useFetch(url, { baseURL, headers, ...props })
}
