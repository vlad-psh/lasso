import helpers from './helpers.js';
const debounce = helpers.debounce;
const axios = require('axios');

Vue.component('vue-search', {
  data() {
    return {
      searchQuery: '',
      previousQuery: '',
      searchResults: [],
      selectedSeq: null,
      wordsSeq: [],
      wordsData: {drills: [], kanjis: [], words: [], paths: []},
      highlightedWordIndex: null,
      axiosSearchToken: null,
    }
  },
  computed: {
  },
  methods: {
    searchDebounce: debounce(function(e = null){this.search(e);}, 250),
    searchExec(query) {
      this.previousQuery = '';
      this.searchQuery = query;
      this.search(-1);
    },
    search(openWordAtIndex = null, popHistory = true) {
      var app = this;
      var query = this.searchQuery;

      // Prevent request while composing japanese text sing IME
      // Otherwise, same (unchanged) request will be sent after each key press
      if (this.searchQuery === this.previousQuery) return;
      if (this.searchQuery.trim() === '') return;

      const cancelTokenSource = axios.CancelToken.source();
      // Cancel current request and replace with new CancelToken
      if (this.axiosSearchToken) this.axiosSearchToken.cancel();
      this.axiosSearchToken = cancelTokenSource;

      const params = new URLSearchParams();
      params.append('query', query);

      axios.post('/search', params, {
        cancelToken: cancelTokenSource.token,
      }).then(resp => {
        // If input field hasn't been changed while we're trying to get results
        if (this.axiosSearchToken === cancelTokenSource) {
          this.axiosSearchToken = null;
        }

        if (query === app.searchQuery) {
          app.highlightedWordIndex = null;
          app.searchResults = resp.data;
          app.previousQuery = query;

          if (popHistory) {
            history.pushState({}, query, '?query=' + query);
          }
          document.title = query;

          if (resp.data.length > 0 && openWordAtIndex !== -1) {
            app.openWord(openWordAtIndex || 0);
          }
        }
      });
    },
    scrollToWord(seq = null) {
      const offset = seq ? $(`[data-seq=${seq}]`)[0].offsetTop - 32 : 0;
      $('.contents-panel').animate({'scrollTop': offset}, 500);
    },
    openWord(index) {
      var app = this;
      var seq = this.searchResults[index][0];
      this.selectedSeq = seq;
      this.highlightedWordIndex = index;

      if (this.wordsSeq.find(i => i === seq)) {
        this.scrollToWord(seq);
      } else {
        this.wordsSeq.unshift(seq);

        $.ajax({
          url: "/api/word",
          method: 'GET',
          data: {seq: seq}
        }).done(data => {
          if (seq === app.selectedSeq) {
            var j = JSON.parse(data);
            app.mergeWordsData(j);
            app.scrollToWord();

            // update current location
            var u = new URLSearchParams(location.search);
            u.set('index', index);
            history.replaceState({}, '', '?' + u.toString());
          }
        }); // end of ajax request
      }
    },
    openWordDebounced: debounce(function(){
      this.openWord(this.highlightedWordIndex);
    }, 250),
    nextResult() {
      if (this.searchResults.length === 0) return;

      if (this.highlightedWordIndex === null) {
        this.highlightedWordIndex = 0;
      } else {
        this.highlightedWordIndex += 1;
      }

      if (this.highlightedWordIndex === this.searchResults.length) {
        this.highlightedWordIndex = 0;
      }

      this.openWordDebounced();
    },
    previousResult() {
      if (this.searchResults.length === 0) return;

      if (this.highlightedWordIndex === null) {
        this.highlightedWordIndex = this.searchResults.length - 1;
      } else {
        this.highlightedWordIndex -= 1;
      }

      if (this.highlightedWordIndex === -1) {
        this.highlightedWordIndex = this.searchResults.length - 1;
      }

      this.openWordDebounced();
    },
    clearInputField() {
      this.searchQuery = '';
      this.previousQuery = '';
    },
    mergeWordsData(data) {
      const kv = {drills: 'id', kanjis: 'id', words: 'seq'};
      for (var k in kv) {
        var v = kv[k];
        for (var i of data[k]) {
          if (!this.wordsData[k].find(j => j[v] === i[v])) this.wordsData[k].push(i);
        }
      };
      this.wordsData.paths = data.paths;
//kanji_summary?, radicals
    },
    hasCachedWord(seq) {
      return this.wordsData.words.find(i => i.seq === seq) ? true : false;
    },
    ...helpers
  }, // end of methods
  mounted() {
    var app = this;
    var loadContent = function () {
      var u = new URLSearchParams(location.search);
      console.log('load content ' + u);
      if (u.has('query')) {
        app.searchQuery = u.get('query');
        app.search(u.has('index') ? Number.parseInt(u.get('index')) : null, false);
      }
      return true;
    }
    loadContent();
    window.onpopstate = loadContent;
  },
  template: `
<div id="search-app">
  <div class="browse-panel">
    <div class="search-field">
      <input type="text" placeholder="Search..." @input="searchDebounce()" v-model="searchQuery" @keydown.esc="clearInputField()" @keydown.down="nextResult()" @keydown.up="previousResult()">
      <div class="loading-circles" v-if="axiosSearchToken"><div></div><div></div><div></div></div>
    </div>
    <div class="search-results">
      <div v-for="(result, resultIndex) in searchResults" :id="'search-result-' + resultIndex" class="result-item no-refocus" :class="[selectedSeq == result[0] ? 'selected' : null, highlightedWordIndex === resultIndex ? 'highlighted' : null]" @click="openWord(resultIndex)">
        <div class="title">
          <div class="common-icon" :class="result[4] ? 'common' : 'uncommon'">&#x2b50;</div>
          <div class="text">{{result[1]}}</div>
          <div v-if="result[5]" class="learned-icon"></div>
        </div>
        <div class="details">{{result[2]}}・{{result[3]}}</div>
      </div>
    </div>
  </div>
  <div class='contents-panel'>
    <template v-for="seq of wordsSeq">
      <vue-word v-if="hasCachedWord(seq)" :seq="seq" :j="wordsData" :editing="true" @search="searchExec" :highlighted="selectedSeq === seq"></vue-word>
      <div v-else>Loading...</div>
    </template>
  </div>
</div>
`
});
