<template>
  <div class="word-krebs">
    <div v-for="kreb of krebs" :key="kreb.title" class="kreb-item">
      <Dropdown trigger="clickToToggle">
        <WordPitch :kreb="kreb" role="button" />
        <template #popper>
          <div class="popper">
            <DrillPopup
              :active-drills="kreb.drills"
              :kreb-title="kreb.title"
              :seq="seq"
            ></DrillPopup>
          </div>
        </template>
      </Dropdown>

      <div v-if="kreb.drills.length > 0" class="drills-counter">
        {{ kreb.drills.length }}
      </div>
      <NuxtLink
        v-if="!kreb.is_kanji"
        class="jisho-search-link"
        :to="searchRoute(kreb)"
        @click.native="search(kreb)"
        >&#x1f50e;</NuxtLink
      >
    </div>
  </div>
</template>

<script setup>
  import { Dropdown } from 'floating-vue'
  import 'floating-vue/dist/style.css'

  defineProps({
    krebs: { type: Array, required: true },
    seq: { type: Number, required: true },
  })

  const store = useSearch()

  const searchRoute = (kreb) => {
    return { name: 'jiten', params: { mode: 'kokugo', query: kreb.title } }
  }

  const search = (kreb) => {
    store.search(kreb.title, 'kokugo', { popRoute: true })
  }
</script>

<style lang="scss">
.kreb-item {
  display: inline-block;
  // margin: 0 0.6em 0 -0.3em;
  margin-right: 0.6em;
  margin-bottom: 0.3em;
  border-bottom: none;

  .v-popper {
    display: inline-block;
  }

  .drills-counter {
    display: inline-block;
    background: #febb10;
    color: #59430a;
    border-radius: 1em;
    width: 1.3em;
    height: 1.3em;
    text-align: center;
    vertical-align: sub;
    font-size: 0.65em;
    line-height: 1.3em;
    margin-left: 0.5em;
  }
}
.word-kreb {
  padding: 0.2em 0.5em;
  font-size: 1.3em;
  position: relative;
  display: inline-block;
  cursor: pointer;
  border: 1px solid var(--grey-tag-border-color);
  border-radius: 0.4em;
  box-shadow: var(--light-shadow);

  &:hover {
    background-image: var(--grey-tag-bg-gradient);
  }

  &.common {
    background-color: var(--purple-tag-bg);
    color: var(--purple-tag-color);
    border-color: transparent;
    box-shadow: none;

    &:hover {
      background-image: var(--purple-tag-bg-gradient);
    }
  }
}
.jisho-search-link {
  // @include non-selectable;
  display: inline-block;
  text-decoration: none;
  font-size: 0.9em;
  &:hover {
    opacity: 0.6;
  }
}
</style>
