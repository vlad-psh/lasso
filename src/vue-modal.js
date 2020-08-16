function prepareModal() {
  var vueModalApp = new Vue({
    el: '#vue-modal',
    data: {
      iframe: null,
      previousCategory: null,
    },
    methods: {
      open(url) {
        document.body.classList.add('modal-active');
        this.iframe = url;
      },
      openKokugo(term) {
        this.assignCategory('kokugo');
        this.open('https://wakame.fruitcode.net/jiten/?book=kokugo&search=' + term);
      },
      openKanji(term) {
        this.assignCategory('kanji');
        this.open('https://wakame.fruitcode.net/jiten/?book=kanji&search=' + term);
      },
      assignCategory(category) {
        this.previousCategory = window.activityCategory;
        window.activityCategory = category;
      },
      close() {
        document.body.classList.remove('modal-active');
        this.iframe = null;
        window.activityCategory = this.previousCategory;
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

