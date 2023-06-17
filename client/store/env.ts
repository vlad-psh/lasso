interface IUser {
  id: number,
  login: string
}

type TActivityGroup = 'search' | 'kokugo' | 'kanji' | 'onomat' | 'other'

export const useEnv = defineStore('env', {
  state: () => ({
    device: 'pc',
    user: undefined as IUser | undefined | null,
    activityGroup: 'other' as TActivityGroup, // group to report study time spend on each section
    quizParams: null,
  }),

  actions: {
    setUser(user: IUser) {
      this.user = user
    },

    setActivityGroup(group: TActivityGroup) {
      this.activityGroup = group
    },

    setQuizParams(params) {
      this.quizParams = params
    },
  },
})
