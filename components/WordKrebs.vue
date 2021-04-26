<template>
  <div class="word-krebs">
    <div v-for="kreb of krebs" :key="kreb.title" class="kreb-item">
      <Popper trigger="clickToToggle">
        <div class="popper">
          <DrillSelect
            :active-drills="kreb.drills"
            :kreb-title="kreb.title"
            :seq="seq"
          ></DrillSelect>
        </div>
        <span slot="reference">
          <PitchWord :kreb="kreb" />
        </span>
      </Popper>

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

<script>
import Popper from 'vue-popperjs'
import 'vue-popperjs/dist/vue-popper.css'

export default {
  components: { Popper },
  props: {
    krebs: { type: Array, required: true },
    seq: { type: Number, required: true },
  },
  methods: {
    searchRoute(kreb) {
      return { name: 'sub-search', params: { query: kreb.title } }
    },
    search(kreb) {
      this.$search.execute({
        query: kreb.title,
        popRoute: true,
        mode: 'kokugo',
      })
    },
  },
}
</script>

<style lang="scss">
.kreb-item {
  display: inline-block;
  // margin: 0 0.6em 0 -0.3em;
  margin-right: 0.6em;
  margin-bottom: 0.3em;
  border-bottom: none;

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
    margin-left: -0.5em;
  }
}
.word-kreb {
  font-size: 1.4em;
  position: relative;
  display: inline-block;
  cursor: pointer;
  border: none;
  padding: 0 0.3em 0.2em 0.3em; // bottom padding needed so that bottom border will not intersects with pitch accent
  /* transparent border; so that height is equal with common words with visible border*/
  border-bottom: 2px solid rgba(255, 255, 255, 0);

  &.common {
    border-bottom-color: green;
    border-bottom-style: dotted;
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
body .popper {
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

html[class='dark-mode'] body .popper {
  box-shadow: #000 0 0 100px 0;
  &,
  .popper__arrow {
    background-color: var(--bg-secondary);
    color: var(--color);
  }
}
</style>
