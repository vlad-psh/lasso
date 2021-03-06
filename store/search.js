export const state = () => ({
  query: '', // query value for completed search
  results: [], // candidates array (short info)
  selectedIdx: -1,
  selected: null,
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
      state.selected = {
        type: 'word',
        seq: sel[0],
      }
    }
  },
}

export const actions = {
  async search(ctx, query) {
    // Prevent request while composing japanese text using IME
    // Otherwise, same (unchanged) request will be sent after each key press
    if (!query) return false
    if (query === ctx.state.query) return true
    if (query.trim() === '') return false

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
      if (ctx.state.axiosCancelHandler !== axiosCancelHandler) return false

      // Reset cancel handler is important on server side so we don't try to send it to client
      ctx.commit('RESET_AXIOS_CANCEL_HANDLER')
      ctx.commit('SET_RESULTS', { query, results: resp.data })

      return true
    } catch (e) {
      // If request was canceled or failed
      return false
    }
  },
  selectSeq(ctx, seq) {
    seq = +seq
    const idx = ctx.state.results.findIndex((i) => i[0] === seq)
    ctx.commit('SET_IDX', idx === -1 ? 0 : idx)
  },
}

export const getters = {
  selectedSeq(state) {
    return (state.results[state.selectedIdx] || [])[0]
  },
}
