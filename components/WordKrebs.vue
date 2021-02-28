<template>
  <div class="word-krebs">
    <div v-for="kreb of krebs" :key="kreb.title" class="kreb-item">
      <Modal :title="kreb.title">
        <div slot="content">
          <table>
            <tr>
              <td v-if="selectedKreb.pitch">Pitch: {{ selectedKreb.pitch }}</td>
              <!-- <td>
              <vue-learn-buttons
                :progress="selectedKreb.progress"
                :post-data="{ id: seq, title: selectedKreb, kind: 'w' }"
                :editing="editing"
                @update-progress="updateKrebProgress($event)"
              ></vue-learn-buttons>
            </td> -->
              <td>
                Drills:
                {{ selectedKreb.drills }}
              </td>
              <td>
                <input type="button" value="Add" @click="addKrebToDrill()" />
              </td>
            </tr>
          </table>
        </div>

        <PitchWord :kreb="kreb" />
      </Modal>
      <NuxtLink class="jisho-search-link" :to="searchRoute(kreb)"
        >&#x1f50e;</NuxtLink
      >
      <div
        v-if="kreb.title === selectedKreb.title"
        class="expandable-list-arrow"
      ></div>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    krebs: { type: Array, required: true },
  },
  data() {
    return {
      selectedKreb: {},
    }
  },
  methods: {
    searchRoute(kreb) {
      return { name: 'search-query', params: { query: kreb.title } }
    },
  },
}
</script>

<style lang="scss">
.kreb-item {
  display: inline-block;
  // margin: 0 0.6em 0 -0.3em;
  margin-right: 0.6em;
  border-bottom: none;
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
</style>
