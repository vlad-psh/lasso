function prepareModal() {
  var vueModalApp = new Vue({
    el: '#vue-modal',
    data: {
      iframe: null,
    },
    methods: {
      open(url) {
        document.body.classList.add('modal-active');
        this.iframe = url;
      },
      close() {
        document.body.classList.remove('modal-active');
        this.iframe = null;
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

