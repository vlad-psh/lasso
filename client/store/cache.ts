interface IWordResponse {
  words: IWord[],
  kanjis: IKanji[],
}

interface ICache {
  words: IWordsCollection,
  kanji: IKanjiCollection,
  drills: IDrill[] | null,
  history: any[],
}

export const useCache = defineStore('cache', {
  state: (): ICache => ({
    words: {},
    kanji: {},
    drills: null,
    history: [],
  }),

  actions: {
    async loadWord(seq: number) {
      if (this.words[seq]) return this.words[seq]

      try {
        // TODO: cancel existing requests if possible with $fetch
        const resp = await $fetch<string>('/api/word', { params: { seq }})
        const json = JSON.parse(resp) as IWordResponse

        for (const word of json.words) this.pushWord(word)
        for (const kanji of json.kanjis) this.addKanji(kanji)

        return this.words[seq]
      } catch (e) {
        console.error('Request failed:', e)
      }
    },

    async loadDrills(force = false) {
      if (this.drills !== null && !force) return

      try {
        const resp = await $fetch<string>('/api/drills')
        this.drills = JSON.parse(resp)
      } catch (e) {
        this.drills = null
      }
    },

    pushWord(word: IWord) {
      this.words[word.seq] = word
      // TODO: Keep only N recent words
      // TODO: If we're pushing words from quiz's sentence, we might have more than 10 words
    },

    addKanji(kanji: IKanji) {
      if (!kanji.progress.comment) kanji.progress.comment = null
      this.kanji[kanji.title] = kanji
    },

    addHistory(val) {
      this.history.unshift(val)
    },

    updateWordComment({ seq, text }: { seq: number, text: string }) {
      const w = this.words[seq]
      if (w) w.comment = text
    },

    updateKanjiComment({ kanji, text }: { kanji: string, text: string }) {
      const k = this.kanji[kanji]
      if (k) k.progress.comment = text
    },

    updateDrill(drill: IDrill) {
      const index = this.drills.findIndex((i) => i.id === drill.id)
      if (index !== -1) {
        this.drills[index] = drill
      }
    },

    addDrill(drill: IDrill) {
      this.drills.unshift(drill)
    },
  },
})
