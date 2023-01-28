<template>
  <div v-if="drills.length > 0">
    <BookmarkIcon />
    <div class="word-drills-list">
      <div
        v-for="(drill, idx) of drills"
        :key="`drill-${idx}`"
        class="drill-label"
      >
        {{ drill.title }}
      </div>
    </div>
  </div>
</template>

<script>
import BookmarkIcon from '@/assets/icons/bookmark.svg?inline'

export default {
  components: { BookmarkIcon },
  props: {
    word: { type: Object, required: true },
  },
  computed: {
    drills() {
      const drills = this.$store.state.cache.drills || []

      const drillObjs = this.word.krebs
        .reduce(
          (acc, kreb) => (kreb.drills ? [...acc, ...kreb.drills] : acc),
          []
        )
        .map(
          (id) =>
            drills.find((drill) => drill.id === id) || {
              id,
              title: `Drill #${id}`,
            }
        )
        .filter((drill) => drill !== undefined)

      return drillObjs
    },
  },
}
</script>

<style lang="scss" scoped>
svg {
  width: 1em;
  height: 1em;
  vertical-align: middle;
}

.word-drills-list {
  display: inline-flex;
  column-gap: 0.4em;
  margin-left: 0.2em;
}

.drill-label {
  display: inline-block;
  font-family: sans-serif;
  font-size: 0.55em;
  font-weight: bold;
  text-transform: uppercase;
  background: rgb(233, 235, 240);
  color: rgb(96, 97, 100);
  border-radius: 0.2em;
  padding: 0.1em 0.5em;
}
</style>
