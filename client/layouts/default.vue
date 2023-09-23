<template>
  <div id="__layout_inner">
    <template v-if="route.name === 'signup-token'">
      <slot />
    </template>

    <template v-else-if="env.user">
      <MainMenu />
      <!-- <Nuxt keep-alive /> -->
      <div class="main-content">
        <slot />
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

  .main-content {
    margin-top: var(--menu-height);
  }

 .popper {
    background-color: #fff;
    box-shadow: #555 0 0 100px 0;
    padding: 0;
    border-radius: 0.5em;
    border: none;

    .popper__arrow {
      border: none;
      width: 25px;
      height: 11px;
      background-color: white;
      mask-image: url('assets/icons/popover-arrow.svg');
      mask-size: 25px 11px;
    }

    &[x-placement^='bottom'] {
      margin-top: 22px;
      .popper__arrow {
        top: -10.5px;
      }
    }
    &[x-placement^='top'] {
      margin-bottom: 22px;
      .popper__arrow {
        bottom: -10.5px;
        transform: rotate(180deg);
      }
    }
  }
}

html[class='dark-mode'] body {
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

  .popper {
    box-shadow: #000 0 0 100px 0;
    &,
    .popper__arrow {
      background-color: var(--bg-secondary);
      color: var(--color);
    }
  }
}
</style>
