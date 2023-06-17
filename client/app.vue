<template>
  <NuxtLayout>
    <!-- <NuxtPage /> -->
    Hello nuxt 3.5
  </NuxtLayout>
</template>

<script setup lang="ts">
  const route = useRoute();
</script>

<style lang="scss">
@import url('https://fonts.googleapis.com/css2?family=M+PLUS+Rounded+1c:wght@300;400&display=swap');

body {
  margin: 0;
  color: var(--color);

  font-family: 'PT Sans', 'Helvetica Neue', 'M PLUS Rounded 1c', serif;
  font-size: 16.4px;
  font-weight: 400;

  .ja {
    font-family: 'M PLUS Rounded 1c', serif;
    font-weight: 300;
    line-height: 1.6em;
  }

  .en {
    line-height: 1.4em;
  }

  #__layout_inner {
    height: 100vh;
    display: grid;
    grid-template-rows: auto 1fr;
  }

  a {
    color: #008ace;
    &:hover {
      color: #c00;
    }
  }

  .blue {
    background-color: #2196f3;
    color: white;
  }
  .green {
    background-color: #4caf50;
    color: white;
  }
  .purple {
    background-color: #aa00ff;
    color: white;
  }
  .yellow {
    background-color: #ff9800;
    color: white;
  }
  .red {
    background-color: #e51c23;
    color: white;
  }
  .lime {
    background-color: #aaff00;
    color: white;
  }
  .pink {
    background-color: #ff00aa;
    color: white;
  }

  .middle-content {
    overflow-y: scroll;
    padding: 0 calc((100vw - 40em) / 2);
    text-align: center;
  }

  svg.svg-icon {
    height: 1.5em;
    width: 1.5em;
    margin-bottom: -0.4em;
  }

  input,
  textarea {
    font-family: inherit;
    font-size: inherit;
    font-weight: inherit;
  }
}

html[class='dark-mode'] body {
  background: var(--bg);
  color: var(--color);

  .blue {
    background-color: var(--bg-secondary);
    border: 0px solid #2196f3;
  }
  .green {
    background-color: #0a3f39;
    border: 0px solid #4caf50;
  }
  .purple {
    background-color: #53155e;
    border: 0px solid #9c27b0;
  }
  .yellow {
    background-color: #c97a04;
    border: 0px solid #ff9800;
  }
  .red {
    background-color: #56181a;
    border: 0px solid #e51c23;
  }
  .lime {
    background-color: #629300;
    border: 0px solid #aaff00;
  }
  .pink {
    background-color: #89005b;
    border: 0px solid #ff00aa;
  }

  input[type='text'],
  textarea {
    background: var(--bg-secondary);
    color: var(--color);
    border: none;
  }

  #main-menu {
    background-color: var(--bg-secondary);
  }
}

@media (max-width: 950px) {
  body {
    font-size: 14px;

    .en {
      font-size: 1.1em;
    }
  }
}

@media (max-width: 568px) {
  body {
    input[type='text'],
    input[type='password'],
    textarea {
      font-size: clamp(16px, 1em, 2em) !important;
    }
  }
}

@keyframes LoadingBackground {
  0% {
    background-position: 1% 0%;
  }
  50% {
    background-position: 99% 100%;
  }
  100% {
    background-position: 1% 0%;
  }
}
</style>
