<template>
  <div class="jiten-navigation">
    <input
      class="shortkey-enabled"
      v-model="page"
      @keydown.enter="commitPageChange"
      v-shortkey="{
        rightPage: ['shift', 'arrowright'],
        leftPage: ['shift', 'arrowleft'],
      }"
      @shortkey="changePage"
    />
  </div>
</template>

<script>
export default {
  data() {
    return {
      page: null,
    }
  },
  mounted() {
    this.page = this.statePage
  },
  computed: {
    statePage() {
      return this.$store.state.search.current.page
    },
  },
  watch: {
    statePage(newPage, __oldPage) {
      this.page = newPage
    },
  },
  methods: {
    commitPageChange() {
      this.$store.commit('search/SET_CURRENT', {
        ...this.$store.state.search.current,
        page: this.page,
      })
    },
    changePage(event) {
      // Currently we only have books with reverse page order, so 'left' is the 'next page'
      if (event.srcKey === 'leftPage') {
        this.page++
      } else if (event.srcKey === 'rightPage') {
        this.page--
      }
      this.commitPageChange()
    },
  },
}
</script>

<style lang="scss"></style>
