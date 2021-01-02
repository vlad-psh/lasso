export const state = () => ({
  previousQuery: '',
  searchResults: [],
  selectedSeq: null,
  words: [],
  highlightedWordIndex: -1,
  axiosCancelHandler: null,
})

export const mutations = {
  RESET_AXIOS_CANCEL_HANDLER(state) {
    try {
      state.axiosCancelHandler.cancel()
    } catch {
      // Nothing to do (eg: request already finished)
    }
    state.axiosCancelHandler = null
  },
  SET_AXIOS_CANCEL_HANDLER(state, val) {
    state.axiosCancelHandler = val
  },
  SET_RESULTS(state, { query, results }) {
    state.highlightedWordIndex = null
    state.searchResults = results
    state.previousQuery = query
  },
  SET_SEL_IDX(state, val) {
    state.highlightedWordIndex = val
  },
  SEL_IDX_INCR(state) {
    state.highlightedWordIndex =
      state.highlightedWordIndex >= state.searchResults.length - 1
        ? 0
        : state.highlightedWordIndex + 1
  },
  SEL_IDX_DECR(state) {
    state.highlightedWordIndex =
      state.highlightedWordIndex === 0
        ? state.searchResults.length - 1
        : state.highlightedWordIndex - 1
  },
}

export const actions = {
  async search(ctx, { query, index = null }) {
    // Prevent request while composing japanese text using IME
    // Otherwise, same (unchanged) request will be sent after each key press
    if (!query) return
    if (query === ctx.state.previousQuery) return
    if (query.trim() === '') return

    const axiosCancelHandler = this.$axios.CancelToken.source()
    const cancelToken = axiosCancelHandler.token
    // Cancel current request (if any) and replace with new CancelToken
    ctx.commit('RESET_AXIOS_CANCEL_HANDLER')
    ctx.commit('SET_AXIOS_CANCEL_HANDLER', axiosCancelHandler)

    try {
      const resp = await this.$axios.post(
        '/api/search',
        { query },
        { cancelToken }
      )
      // Check if cancelHandler is still the same (haven't overwritten by new search request)
      if (ctx.state.axiosCancelHandler !== axiosCancelHandler) return

      ctx.commit('RESET_AXIOS_CANCEL_HANDLER')
      ctx.commit('SET_RESULTS', { query, results: resp.data })

      if (resp.data.length > 0) {
        ctx.commit('SET_SEL_IDX', index || 0)
      }
    } catch (e) {
      // If request was canceled or failed
      if (ctx.state.axiosCancelHandler !== axiosCancelHandler)
        ctx.commit('RESET_AXIOS_CANCEL_HANDLER')
    }
  },
}
