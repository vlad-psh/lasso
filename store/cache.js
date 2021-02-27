export const state = () => ({
  words: {},
  kanji: {},
  drills: {},
  history: [],
})

export const mutations = {
  PUSH_WORD(state, word) {
    this._vm.$set(state.words, word.seq, word)
    // TODO: Keep only N recent words
    // TODO: If we're pushing words from quiz's sentence, we might have more than 10 words
  },
  ADD_KANJI(state, kanji) {
    this._vm.$set(state.kanji, kanji.title, kanji)
  },
  ADD_HISTORY(state, val) {
    state.history.unshift(val)
  },
}

export const actions = {
  async loadWord(ctx, seq) {
    if (!ctx.state.words[seq])
      try {
        // TODO: cancel token
        const resp = await this.$axios.get('/api/word', { params: { seq } })
        for (const word of resp.data.words) ctx.commit('PUSH_WORD', word)
        for (const kanji of resp.data.kanjis) ctx.commit('ADD_KANJI', kanji)
      } catch (e) {}
    return ctx.state.words[seq]
  },
}
