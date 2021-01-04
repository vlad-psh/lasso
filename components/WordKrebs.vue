<template>
  <div class="center-block">
    <div class="word-krebs expandable-list">
      <div v-for="kreb of krebs" :key="kreb.title" class="expandable-list-item">
        <div>
          <div
            class="word-kreb no-refocus"
            :class="[
              kreb.is_common ? 'common' : null,
              kreb.progress.learned_at ? 'learned' : null,
            ]"
            @click="openKrebForm(kreb)"
          >
            <PitchWord :word="kreb.title" :pitch="kreb.pitch" />
          </div>
          <a
            class="jisho-search-link"
            :href="'/jiten/?book=kokugo&search=' + kreb.title"
            target="_blank"
            @click.prevent.stop="modalOpen(kreb.title)"
            >&#x1f50e;</a
          >
        </div>
        <div
          v-if="kreb.title === selectedKreb.title"
          class="expandable-list-arrow"
        ></div>
      </div>
    </div>

    <!-- expanded word properties -->
    <div
      v-if="selectedKreb.title"
      class="expandable-list-container word-kreb-expanded"
    >
      <div class="center-block">
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
  computed: {},
  methods: {
    openKrebForm(kreb) {
      this.selectedKreb = this.selectedKreb === kreb ? {} : kreb
    },
  },
}
</script>
