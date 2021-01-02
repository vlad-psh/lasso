<template>
  <div class="loading-circles">
    <div></div>
    <div></div>
    <div></div>
  </div>
</template>

<style lang="scss">
.loading-circles {
  position: absolute;
  right: 1em;
  top: 0.8em;
  font-size: 0.8em;
  line-height: 1em;

  div {
    display: inline-block;
    width: 0.6em;
    height: 0.6em;
    border-radius: 0.3em;
    margin: 0 0.2em;
    background-color: #555;

    animation-name: eq-bar;
    animation-play-state: running;
    animation-direction: alternate;
    animation-timing-function: ease-in-out;
    animation-iteration-count: infinite;
    transform-origin: center center;

    -webkit-animation-name: loading-circle;
    -webkit-animation-play-state: running;
    -webkit-animation-direction: alternate;
    -webkit-animation-timing-function: ease-in-out;
    -webkit-animation-iteration-count: infinite;
    -webkit-transform-origin: center center;

    &:nth-child(1) {
      animation-duration: 300ms;
      animation-delay: -200ms;
      -webkit-animation-duration: 300ms;
      -webkit-animation-delay: -200ms;
    }
    &:nth-child(2) {
      animation-duration: 300ms;
      animation-delay: -100ms;
      -webkit-animation-duration: 300ms;
      -webkit-animation-delay: -100ms;
    }
    &:nth-child(3) {
      animation-duration: 300ms;
      animation-delay: 0ms;
      -webkit-animation-duration: 300ms;
      -webkit-animation-delay: 0ms;
    }
  }
}

@keyframes loading-circle {
  0% {
    -webkit-transform: scale(0.2, 0.2);
    transform: scale(0.2, 0.2);
  }
  100% {
    -webkit-transform: none;
    transform: none;
  }
}
</style>
