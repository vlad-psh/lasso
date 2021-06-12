export const state = () => ({
  words: {},
  kanji: {},
  drills: null,
  history: [],
})

export const mutations = {
  PUSH_WORD(state, word) {
    this._vm.$set(state.words, word.seq, word)
    // TODO: Keep only N recent words
    // TODO: If we're pushing words from quiz's sentence, we might have more than 10 words
  },
  ADD_KANJI(state, kanji) {
    if (!kanji.progress.comment) kanji.progress.comment = null
    this._vm.$set(state.kanji, kanji.title, kanji)
  },
  ADD_HISTORY(state, val) {
    state.history.unshift(val)
  },
  SET_DRILLS(state, val) {
    state.drills = val
  },
  UPDATE_WORD_COMMENT(state, { seq, text }) {
    const w = state.words[seq]
    if (w) w.comment = text
  },
  UPDATE_KANJI_COMMENT(state, { kanji, text }) {
    const k = state.kanji[kanji]
    if (k) k.progress.comment = text
  },
  UPDATE_DRILL(state, drill) {
    const index = state.drills.findIndex((i) => i.id === drill.id)
    if (index !== -1) {
      this._vm.$set(state.drills, index, drill)
    }
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
  async loadDrills(ctx, force = false) {
    if (ctx.state.drills === null || force) {
      try {
        ctx.commit('SET_DRILLS', [])
        const resp = await this.$axios.get('/api/drills')
        ctx.commit('SET_DRILLS', resp.data)
      } catch (e) {}
    }
  },
}
