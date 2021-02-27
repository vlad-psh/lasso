export default async (context, inject) => {
  const { store, query } = context
  await store.dispatch('search/search', {
    query: query.query,
    seq: +query.seq,
  })
}
