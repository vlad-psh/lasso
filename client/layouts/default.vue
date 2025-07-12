<template>
  <div id="__layout_inner">
    <template v-if="route.name === 'signup-token'">
      <NuxtPage />
    </template>

    <template v-else-if="env.user">
      <MainMenu />
      <div class="main-content">
        <NuxtPage />
      </div>
    </template>

    <LoginForm v-else-if="env.user === null" />
  </div>
</template>

<script setup>
  const route = useRoute()
  const env = useEnv()

  useOriginFetch('/api/session')
    .then(resp => env.setUser(JSON.parse(resp.data.value)))
    .catch(_error => env.setUser(null))
</script>

<style lang="scss">
body {
  --color: rgb(41, 47, 57);
  --bg: #fff;
  --bg-secondary: #f0f0f0;

  --border-color: rgb(0, 5, 10, 0.05);

  --light-shadow: rgba(0, 0, 0, 0.05) 0px 1px 2px 0px;
  --darker-bg: rgba(249, 250, 251, 1);

  --purple-tag-bg: #f5f3ff;
  --purple-tag-color: #5b21b6;
  --purple-tag-bg-gradient: linear-gradient(
    to bottom,
    var(--purple-tag-bg),
    #ede9fe
  );

  --grey-tag-bg: transparent;
  --grey-tag-bg-gradient: linear-gradient(to bottom, transparent, #f3f4f6);
  --grey-tag-border-color: var(--border-color);

  --menu-height: 2.5rem;
  --menu-bg-color: #222;
  --search-input-width: clamp(10em, 25vw, 22em);

  .main-content {
    margin-top: var(--menu-height);
  }
}

html[class~='dark-mode'] body {
  --color: #ccc; // main text color
  --color-secondary: #8799a5; // little bit darker text
  --bg: #16202a; // #0d192b
  --bg-secondary: #1c2939; // top menu bg, etc; little bit lighter

  --border-color: rgba(128, 128, 128, 0.2);
  --darker-bg: rgba(249, 250, 251, 0.02);

  --purple-tag-bg: #4929ea3b;
  --purple-tag-color: #f5f3ff;
  --purple-tag-bg-gradient: linear-gradient(
    to bottom,
    var(--purple-tag-bg),
    rgb(59, 22, 217)
  );

  --grey-tag-bg-gradient: linear-gradient(to bottom, transparent, #f3f4f610);
}
</style>

<style lang="scss">
body .popper {
  --popper-theme-background-color: #fff;
  --popper-theme-background-color-hover: var(--popper-theme-background-color);
  --popper-theme-text-color: black;
  --popper-theme-border-radius: 0.5em;
  --popper-theme-padding: 0;
  --popper-theme-box-shadow: #555 0 0 100px 0;

  #arrow {
    &::before {
      border: none;
      width: 25px;
      height: 11px;
      background-color: white;
      mask-image: url('assets/icons/popover-arrow.svg');
      mask-size: 25px 11px;
      visibility: visible;
    }
  }

  &[data-popper-placement^='bottom'] {
    #arrow::before {
      top: -6px;
      left: -8px;
      transform: rotate(0deg);
    }
  }
  &[data-popper-placement^='top'] {
    #arrow::before {
      bottom: -10.5px;
      left: -8px;
      transform: rotate(180deg);
    }
  }
  &[data-popper-placement^='right'] {
    #arrow::before {
      left: -13px;
      transform: rotate(270deg);
    }
  }
}
</style>
