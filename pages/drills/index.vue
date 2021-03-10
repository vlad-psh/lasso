<template>
  <div class="drills-list middle-content">
    <h1>Drills</h1>
    <div class="table">
      <div v-for="drill of drills" :key="drill.id" class="drill">
        <div>{{ drill.is_active ? '✏️' : null }}</div>
        <div>
          <NuxtLink :to="'/drills/' + drill.id">{{ drill.title }}</NuxtLink>
          <div class="created-at">{{ drill.created_at }}</div>
        </div>
        <div>
          <NuxtLink
            :to="{
              name: 'sub-quiz',
              params: { drill_id: drill.id, type: 'sentences' },
            }"
            >文読</NuxtLink
          >
        </div>
        <div>
          <NuxtLink
            :to="{
              name: 'sub-quiz',
              params: { drill_id: drill.id, type: 'sentence-kanji' },
            }"
            >文書</NuxtLink
          >
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  async asyncData({ $axios }) {
    const resp = await $axios.get('/api/drills')
    return { drills: resp.data }
  },
  methods: {},
}
</script>

<style lang="scss">
.drills-list {
  .table {
    display: table;
    text-align: left;
    margin: 0 auto;

    .drill {
      display: table-row;
      &:nth-child(even) {
        background: #9872;
      }

      & > div {
        display: table-cell;
        padding: 0.1em 0.2em;
      }

      .created-at {
        opacity: 0.7;
        font-size: 0.75em;
      }
    }
  }
}
</style>
