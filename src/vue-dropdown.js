Vue.component('vue-dropdown', {
//  directives: {onClickaway: VueClickaway.directive},
  props: {
    inputAttributes: Object,
    options: {type: Array, required: true},
    emptyItem: {type: String, required: false},
    titleKey: {type: String, default: 'title'},
    valueKey: {type: String, default: 'value'},
    selectedValue: [String, Number]
  },
  data: function(){
    return {
      expanded: false
    }
  },
  computed: {
    selectedTitle() {
      return this.options.find(i => i[this.valueKey] == this.selectedValue)[this.titleKey];
    }
  },
  methods: {
    selectOption(i){
      this.expanded = false;
      this.$emit('selected', this.options[i][this.valueKey]);
    },
    openMenu(){
      this.expanded = true;
    },
    clickOutside(){
      this.expanded = false;
    }
  },
  created(){
    if (this.emptyItem) {
      var e = {};
      e[this.titleKey] = this.emptyItem;
      e[this.valueKey] = null;
      this.options.unshift(e);
    }
  },
  template: `
    <div class="vue-dropdown">
      <input type="text" v-model="selectedValue" v-bind="inputAttributes" style="display: none;">
      <div class="vue-dropdown-component vue-dropdown-arrow" :class="expanded? 'vue-dropdown-expanded' : ''">
        <div class="vue-dropdown-input" @click="openMenu">
          <div class="item">{{selectedTitle}}</div>
        </div>
        <div v-if="expanded" class="vue-dropdown-wrapper" v-on-clickaway="clickOutside">
          <div class="vue-dropdown-content">
            <div v-for="(option, optionIndex) in options" class="option" @click="selectOption(optionIndex)">{{option.title}}</div>
          </div>
        </div>
      </div>
    </div>
  `
});
