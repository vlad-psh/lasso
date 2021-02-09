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
  SET_IDX(state, val) {
    const sel = state.results[val]
    if (sel) {
      state.selectedIdx = val
      state.selectedSeq = sel[0]
    }
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
        await ctx.dispatch('selectIndex', index || 0)
      }
    } catch (e) {
      // If request was canceled or failed
      if (ctx.state.axiosCancelHandler !== axiosCancelHandler)
        ctx.commit('RESET_AXIOS_CANCEL_HANDLER')
    }
  },
  async selectIndex(ctx, idx) {
    if (idx === 'incr') {
      idx =
        ctx.state.selectedIdx >= ctx.state.results.length - 1
          ? 0
          : ctx.state.selectedIdx + 1
    } else if (idx === 'decr') {
      idx =
        ctx.state.selectedIdx === 0
          ? ctx.state.results.length - 1
          : ctx.state.selectedIdx - 1
    }
    ctx.commit('SET_IDX', idx)
    await ctx.dispatch('cache/loadWord', ctx.state.selectedSeq, { root: true })
  },
}
