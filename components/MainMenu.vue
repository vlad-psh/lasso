<template>
  <div id="main-menu">
    <div class="center">
      <div class="main-menu-item">
        <NuxtLink class="icon" to="/"><SearchIcon /></NuxtLink>
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
      <div class="main-menu-item">
        <a href="/logout">
          <span class="username">USERNAME</span>
        </a>
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
  margin: 0;
  color: white;
  font-family: Segoe UI, Helvetica Neue, sans-serif;
  width: 100%;

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
    .username {
      font-size: 0.7em;
    }
  }
} /* end of #main-menu */
</style>
