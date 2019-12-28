Vue.component('vue-kanji-card', {
  props: {
    kanji: {type: String, required: true},
    grade: {type: Number, required: false},
    learned: {type: Boolean, default: false}
  },
  data() {
    return {
    }
  },
  computed: {
  },
  methods: {
    gradeText(grade){
      if (grade >=1 && grade <= 6) {
        return [null, '１', '２', '３', '４', '５', '６'][grade] + '年';
      } else if (grade == 8) {
        return '常用';
      } else if (grade == 9 || grade == 10) {
        return '人名';
      } else {
        return '表外';
      }
    },
  },
  template: `
<div class="vue-kanji-card" :class="['grade-' + (grade || 'no'), learned ? 'learned' : null]">{{kanji}}<div class="kanji-grade">{{gradeText(grade)}}</div></div>
`
});
