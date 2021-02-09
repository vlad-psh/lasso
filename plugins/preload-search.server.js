export default async (context, inject) => {
  const { store, query } = context
  await store.dispatch('search/search', {
    query: query.query,
    index: Number.parseInt(query.index),
  })
}
