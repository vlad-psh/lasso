<template>
  <div class="word-loading word-info">
    <div class="krebs">
      <div style="width: 3em" />
      <div style="width: 5em" />
    </div>

    <div class="details">
      <div />
      <div />
      <div style="width: 30%; margin-bottom: 1em" />
      <div />
      <div />
      <div />
      <div style="width: 60%" />
    </div>
  </div>
</template>

<style lang="scss">
.word-loading {
  .krebs div,
  .details div {
    background-image: (linear-gradient(270deg, #80808052, #80808022));
    background-size: 400% 100%;
    margin: 0.3em;
    border-radius: 0.3em;
    animation: LoadingBackground 1s ease-in-out infinite;
    transition: 0.6s;
  }
  .krebs div {
    display: inline-block;
    height: 2em;
  }
  .details div {
    width: 100%;
    height: 1.3em;
  }
}
</style>
