interface IProgress {
  id: number,
  learned_at: string | null,
  burned_at: string | null,
  comment: string | null,
  flagged: boolean,
  html_class: string,
}

interface IKreb {
  title: string,
  pitch?: string,
  is_common: boolean,
  is_kanji: boolean,
  progress: IProgress | {},
  drills: number[],
}

interface IGloss {
  gloss: string[],
  pos?: string[],
}

interface IWkCard {
  title: string,
  level: number,
  meaning: string,
  mmne: string,
  rmne: string,
  pos: string,
  reading: string,
  sentences: {
    en: string,
    ja: string,
  }[],
}

type TParsedSentence = any[]

export interface IWord {
  seq: number,
  krebs: IKreb[],
  meikyo: TParsedSentence,
  en: IGloss[],
  ru: IGloss[],
  jlptn?: number,
  nf: number,
  nhk_data: any,
  kanji: string,
  comment: string,
  cards: IWkCard[],
}

export interface IWordsCollection {
  [seq: number]: IWord,
}

export interface IKanji {
  id: number,
  title: string,
  jp: TParsedSentence,
  on: string[],
  kun: string[],
  english: string[],
  radnum: number,
  grade: number,
  jlptn: number | null,
  similars: { j: string[], n: string[], y: string[], jy: string[] },
  progress: IProgress,
  links: {
    [key: string]: string[],
  },
}

export interface IKanjiCollection {
  [kanji: string]: IKanji,
}

export interface IDrill {
  id: number,
  title: string,
}
