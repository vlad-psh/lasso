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

<script setup>
  const search = useSearch()
  const page = ref(search.current.page)

  const commitPageChange = () => {
    search.updateCurrent({ page: page.value })
  }

  const changePage = (event) => {
    // Currently we only have books with reverse page order, so 'left' is the 'next page'
    if (event.srcKey === 'leftPage') {
      page.value += page.value
    } else if (event.srcKey === 'rightPage') {
      page.value -= page.value
    }
    commitPageChange()
  }
</script>

<style lang="scss"></style>
