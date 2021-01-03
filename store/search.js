export const state = () => ({
  query: '', // query value for completed search
  results: [], // candidates array (short info)
  selectedIdx: -1,
  selectedSeq: null,
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
    state.selectedIdx = null
    state.results = results
    state.query = query
  },
  SELECT_IDX(state, val) {
    const sel = state.results[val]
    if (sel) {
      state.selectedIdx = val
      state.selectedSeq = sel[0]
    }
  },
  SEL_IDX_INCR(state) {
    const idx =
      state.selectedIdx >= state.results.length - 1 ? 0 : state.selectedIdx + 1
    this.commit('search/SELECT_IDX', idx)
  },
  SEL_IDX_DECR(state) {
    const idx =
      state.selectedIdx === 0 ? state.results.length - 1 : state.selectedIdx - 1
    this.commit('search/SELECT_IDX', idx)
  },
}

export const actions = {
  async search(ctx, { query, index = null }) {
    // Prevent request while composing japanese text using IME
    // Otherwise, same (unchanged) request will be sent after each key press
    if (!query) return
    if (query === ctx.state.query) return
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
        ctx.commit('SELECT_IDX', index || 0)
      }
    } catch (e) {
      // If request was canceled or failed
      if (ctx.state.axiosCancelHandler !== axiosCancelHandler)
        ctx.commit('RESET_AXIOS_CANCEL_HANDLER')
    }
  },
}
