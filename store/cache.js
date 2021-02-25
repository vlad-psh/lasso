export const state = () => ({
  words: {},
  kanji: {},
  wordIds: [],
  drills: {},
})

export const mutations = {
  PUSH_WORD(state, word) {
    // If word already cached, delete it (to push it again to the top)
    if (state.wordIds.includes(word.seq)) {
      state.wordIds = state.wordIds.filter((i) => i !== word.seq)
      this._vm.$delete(state.words, word.seq)
    }
    // Keep only 10 recent words
    // TODO: if we're pushing words from quiz's sentence, we might have more than 10 words
    if (state.wordIds.length >= 10) {
      // TODO: also remove unused kanji
      const removedSeq = state.wordIds.pop()
      this._vm.$delete(state.words, removedSeq)
    }
    state.wordIds.unshift(word.seq)
    this._vm.$set(state.words, word.seq, word)
  },
  ADD_KANJI(state, kanji) {
    this._vm.$set(state.kanji, kanji.title, kanji)
  },
}

export const actions = {
  async loadWord(ctx, seq) {
    // TODO: maybe do not make another request if requested word is already cached?
    try {
      // TODO: cancel token
      const resp = await this.$axios.get('/api/word', { params: { seq } })
      for (const word of resp.data.words) ctx.commit('PUSH_WORD', word)
      for (const kanji of resp.data.kanjis) ctx.commit('ADD_KANJI', kanji)
    } catch (e) {}
  },
}
