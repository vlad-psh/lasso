import axios from 'axios'

const debounce = function (func, wait, immediate) {
  let timeout
  return function () {
    const context = this
    const args = arguments
    const callNow = immediate && !timeout
    clearTimeout(timeout)
    timeout = setTimeout(function () {
      timeout = null
      if (!immediate) {
        func.apply(context, args)
      }
    }, wait)
    if (callNow) func.apply(context, args)
  }
}

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
    if (state.axiosCancelHandler) {
      state.axiosCancelHandler.cancel()
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
  searchDebounce: debounce(function (ctx, query, options = {}) {
    ctx.dispatch('search', query, options)
  }, 250),
  search(ctx, query, { openWordAtIndex = null, popHistory = true } = {}) {
    // Prevent request while composing japanese text using IME
    // Otherwise, same (unchanged) request will be sent after each key press
    if (query === ctx.state.previousQuery) return
    if (query.trim() === '') return

    const axiosCancelHandler = axios.CancelToken.source()
    const cancelToken = axiosCancelHandler.token
    // Cancel current request and replace with new CancelToken
    ctx.commit('RESET_AXIOS_CANCEL_HANDLER')
    ctx.commit('SET_AXIOS_CANCEL_HANDLER', axiosCancelHandler)

    axios.post('/api/search', { query }, { cancelToken }).then((resp) => {
      if (ctx.state.axiosCancelHandler !== axiosCancelHandler) return
      // Continue if input field hasn't been changed while we're trying to get results
      ctx.commit('RESET_AXIOS_CANCEL_HANDLER')
      ctx.commit('SET_RESULTS', { query, results: resp.data })

      if (popHistory) {
        history.pushState({}, query, '?query=' + query)
      }
      document.title = query

      if (resp.data.length > 0) {
        ctx.commit('SET_SEL_IDX', openWordAtIndex || 0)
      }
    })
  },
}
