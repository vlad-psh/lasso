<template>
  <div id="main-menu">
    <div class="center">
      <div class="main-menu-item">
        <NuxtLink class="icon" :to="$search.path"><SearchIcon /></NuxtLink>
      </div>
      <div class="main-menu-item">
        <NuxtLink class="icon" to="/drills"><BookmarkIcon /></NuxtLink>
      </div>
      <div class="main-menu-item">
        <NuxtLink class="icon" to="/sentences"><TypewriterIcon /></NuxtLink>
      </div>
      <div class="main-menu-item">
        <VueThemeButton />
      </div>
    </div>
    <div class="right">
      <div class="main-menu-item username">
        <template v-if="$store.state.env.user">
          {{ $store.state.env.user.login }}
          <a @click="$auth.logout">logout</a>
        </template>
        <template v-else>
          <NuxtLink to="/login">login</NuxtLink>
        </template>
      </div>
    </div>
  </div>
</template>

<script>
import SearchIcon from '@/assets/icons/search.svg?inline'
import BookmarkIcon from '@/assets/icons/bookmark.svg?inline'
import TypewriterIcon from '@/assets/icons/typewriter.svg?inline'

export default {
  components: { SearchIcon, BookmarkIcon, TypewriterIcon },
}
</script>

<style lang="scss">
#main-menu {
  background-color: #222;
  color: white;
  font-family: Segoe UI, Helvetica Neue, sans-serif;

  & > div.center,
  & > div.right {
    display: flex;
    justify-content: center;
    align-items: center;
    min-height: 2em;
  }
  & > div.right {
    position: absolute;
    top: 0;
    right: 0;
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
    }
  }
} /* end of #main-menu */

@media (max-width: 568px) {
  body {
    #main-menu {
      text-align: left;

      & > div.center {
        margin-left: 0.4em;
        justify-content: flex-start;
      }
    }
  }
}
</style>
