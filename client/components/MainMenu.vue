<template>
  <div id="main-menu">
    <SearchInputField />

    <div class="center">
      <div class="main-menu-item">
        <NuxtLink class="icon" to="/drills"><BookmarkIcon /></NuxtLink>
      </div>
      <div v-if="env.quizParams" class="main-menu-item">
        <NuxtLink
          :to="{ name: 'quiz', params: env.quizParams }"
          ><QAIcon
        /></NuxtLink>
      </div>
      <div class="main-menu-item">
        <ThemeButton />
      </div>
    </div>
    <div class="right">
      <div class="main-menu-item username">
        {{ user.login }}
        <a @click="logout">logout</a>
      </div>
    </div>
  </div>
</template>

<script setup>
  import { storeToRefs } from 'pinia'

  import BookmarkIcon from '../assets/icons/bookmark.svg'
  import QAIcon from 'assets/icons/qa.svg'

  const env = useEnv()
  const search = useSearch()
  const { user } = storeToRefs(env)

  const logout = () => {
    $fetch('/api/session', { method: 'DELETE' })
    env.setUser(null)
  }
</script>

<style lang="scss">
#main-menu {
  position: fixed;
  z-index: 100;
  top: 0;
  left: 0;
  width: 100%;
  background-color: var(--menu-bg-color);
  color: white;
  font-family: Segoe UI, Helvetica Neue, sans-serif;
  display: flex;
  justify-content: flex-start;

  & > div.center,
  & > div.right {
    display: flex;
    justify-content: center;
    align-items: center;
    height: var(--menu-height);
  }
  & > div.center {
    flex-grow: 100;
  }
  & > div.right {
    flex-grow: 50;
    justify-content: flex-end;
  }
  .main-menu-item {
    a {
      color: #eee;
      text-decoration: none;
      padding: 0.7em;
      line-height: 1em;
      cursor: pointer;

      &:hover {
        opacity: 0.5;
      }
      &.icon svg {
        width: 16px;
        height: 16px;
      }
    }
    &.username {
      font-size: 0.7em;
      padding: 0.7em;
    }
  }
} /* end of #main-menu */

@media (max-width: 568px) {
  body {
    #main-menu {
      flex-direction: row-reverse;

      & > div.right {
        flex-grow: 0;
        justify-content: flex-start;
      }
    }
  }
}
</style>
