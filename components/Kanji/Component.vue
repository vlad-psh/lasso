<template>
  <div class="vue-kanji">
    <div class="kanji-title no-refocus" :class="htmlClass">
      <NuxtLink :to="searchRoute" @click.native="search">{{
        payload.title
      }}</NuxtLink>
    </div>

    <div class="kanji-details-string">
      <div class="deco" :class="htmlClass">{{ gradeText }}</div>
      <div v-if="payload.jlptn">&#x1f4ae; N{{ payload.jlptn }}</div>
      <div class="deco black">部首</div>
      <span>{{ classicalRadical }}</span>
      <NuxtLink :to="bookSearchRoute" @click.native="searchBook"
        >&#x1f50e;</NuxtLink
      >

      <template v-if="payload.links"
        ><div class="deco yellow">成立</div>
        <a
          v-for="urlHash of payload.links.ishiseiji"
          :key="urlHash"
          :href="'https://blog.goo.ne.jp/ishiseiji/e/' + urlHash"
          target="_blank"
          >{{ payload.title }}</a
        ></template
      >

      <template v-if="payload.on && payload.on.length > 0">
        <div class="deco pink">音</div>
        <div v-for="v of payload.on" :key="v" class="separate">
          {{ v }}<wbr />
        </div>
      </template>

      <template v-if="payload.kun && payload.kun.length > 0">
        <div class="deco blue">訓</div>
        <div v-for="v of payload.kun" :key="v" class="separate">
          <span v-text="v.split('.')[0]" /><span
            v-if="v.split('.').length > 1"
            class="okurigana"
            v-text="v.split('.')[1]"
          /><wbr />
        </div>
      </template>
    </div>

    <KanjiSimilars
      v-for="(similar, idx) of payload.similars"
      :key="'similar' + idx"
      :payload="similar"
    />

    <div v-if="payload.jp" class="definition">
      <FlagJP class="svg-icon" />
      <DefinitionNode
        class="gloss-line"
        :node-name="payload.jp[0].name"
        :children="payload.jp[0].items"
      >
      </DefinitionNode>
    </div>

    <div v-if="payload.english" class="definition">
      <FlagUK class="svg-icon" />
      {{ payload.english.join('; ') }}
    </div>

    <EditableText
      :text-data="payload.progress.comment"
      placeholder="Add comment..."
      @save="saveComment"
    ></EditableText>
  </div>
</template>

<script>
import radicalsList from '@/js/radicals_list.js'
import FlagJP from '@/assets/icons/flag-jp.svg?inline'
import FlagUK from '@/assets/icons/flag-uk.svg?inline'

export default {
  components: { FlagJP, FlagUK },
  props: {
    payload: { type: Object, required: true },
  },
  data() {
    return {}
  },
  computed: {
    learned() {
      return !!this.payload.progress.learned_at
    },
    htmlClass() {
      return [
        'grade-' + (this.payload.grade || 'no'),
        this.payload.learned ? 'learned' : null,
      ]
    },
    gradeText() {
      const grade = this.payload.grade
      if (grade >= 1 && grade <= 6) {
        return [null, '１', '２', '３', '４', '５', '６'][grade] + '年'
      } else if (grade === 8) {
        return '常用'
      } else if (grade === 9 || grade === 10) {
        return '人名'
      } else {
        return '表外'
      }
    },
    classicalRadical() {
      return radicalsList[this.payload.radnum - 1]
    },
    searchRoute() {
      return { name: 'sub-search', params: { query: this.payload.title } }
    },
    bookSearchRoute() {
      return {
        name: 'jiten',
        params: { query: this.payload.title, mode: 'kanji' },
      }
    },
  },
  methods: {
    search() {
      this.$search.execute({
        query: this.payload.title,
        mode: 'primary',
        popRoute: true,
      })
    },
    searchBook() {
      this.$search.execute({
        query: this.payload.title,
        mode: 'kanji',
        popRoute: true,
      })
    },
    saveComment(text, cb) {
      this.$axios
        .post(`/api/kanji/${this.payload.title}/comment`, { comment: text })
        .then((resp) => {
          this.$store.commit('cache/UPDATE_KANJI_COMMENT', {
            kanji: this.payload.title,
            text,
          })
          cb.resolve()
        })
        .catch((e) => {
          cb.reject(e.message)
        })
    },
  },
}
</script>

<style lang="scss">
.vue-kanji {
  .definition {
    line-height: 1.6em;
    padding: 0.3em 0;
  }
}
.kanji-title {
  font-size: 3em;
  line-height: 1em;
  border: 1px solid #7773;
  border-radius: 0.07em;
  float: left;
  margin-right: 0.1em;
  padding: 0.05em;
  background: url('~assets/backgrounds/kanji-grid.svg');
  background-size: 68px 68px;
  background-position: center;

  a {
    color: inherit;
    text-decoration: none;
    cursor: pointer;
  }
}
.kanji-details-string {
  div {
    display: inline-block;
  }
  a {
    cursor: pointer;
  }

  .separate + .separate {
    &:before {
      content: '·';
      margin: 0 0.5em;
    }
  }

  .deco {
    display: inline-block;
    color: white;
    padding: 0.1em 0.2em;
    margin: 0.05em 0 0.05em 0;
    border-radius: 2px;
    font-weight: bold;

    &.grade-1 {
      background: #cc4628;
    }
    &.grade-2 {
      background: #e8b419;
    }
    &.grade-3 {
      background: #e89297;
    }
    &.grade-4 {
      background: #43a057;
    }
    &.grade-5 {
      background: #6ab8c9;
    }
    &.grade-6 {
      background: #51568e;
    }
    &.grade-8 {
      background: black;
    }
    &.grade-9 {
      background: #eabbc3;
    }
    &.grade-10 {
      background: #eabbc3;
    }
    &.grade-no {
      background: #bbe4ea;
    }

    &.pink {
      background: #d37;
    }
    &.blue {
      background: #39d;
    }
    &.black {
      background: #333;
    }
    &.yellow {
      background: #ffe300;
      color: #5e5042;
    }
    &.grey {
      background: #88888815;
      color: #888;
    }
    &.purple {
      background: #b06ac4;
    }
  }

  .okurigana {
    color: #d00;
  }
}

@media (max-width: 568px) {
  body {
    .kanji-title {
      font-size: 2.5em;
    }
    .kanji-details-string {
      font-size: 0.7em;
    }
  }
}
</style>
