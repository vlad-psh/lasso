function prepareModal() {
  var vueModalApp = new Vue({
    el: '#vue-modal',
    data: {
      iframe: null,
      prevCategory: null,
    },
    methods: {
      open(url, category) {
        document.body.classList.add('modal-active');

        this.prevCategory = window.activityCategory;
        window.activityCategory = category;

        this.iframe = url;
      },
      openKokugo(term) {
        this.open('https://wakame.fruitcode.net/jiten/?book=kokugo&search=' + term, 'kokugo');
      },
      openKanji(term) {
        this.open('https://wakame.fruitcode.net/jiten/?book=kanji&search=' + term, 'kanji');
      },
      openSearch(term) {
        this.open('/?modal=1&query=' + term, 'search');
      },
      close() {
        document.body.classList.remove('modal-active');
        this.iframe = null;
        window.activityCategory = this.prevCategory;
      },
    },
    mounted() {
      window.vueModal = this;
    }
  });
};

if (document.readyState != 'loading'){
  prepareModal();
} else {
  document.addEventListener('DOMContentLoaded', prepareModal);
}

