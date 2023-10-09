<template>
  <div class="drills-list middle-content">
    <h1>Drills</h1>

    <DrillCreateNew />

    <div class="table">
      <div
        v-for="drill of cache.drills"
        :key="drill.id"
        class="drill"
      >
        <a
          @click="() => toggleActive(drill.id, !drill.is_active)"
          class="active-icon"
        >
          {{ drill.is_active ? '✏️' : '　' }}
        </a>
        <div>
          <NuxtLink :to="'/drills/' + drill.id">{{ drill.title }}</NuxtLink>
          <div class="created-at">{{ drill.created_at }}</div>
        </div>
        <div>
          <NuxtLink
            :to="{
              name: 'quiz',
              params: { drill_id: drill.id, type: 'reading' },
            }"
            class="quiz-link"
            >📰</NuxtLink
          >
        </div>
        <div>
          <NuxtLink
            :to="{
              name: 'quiz',
              params: { drill_id: drill.id, type: 'writing' },
            }"
            class="quiz-link"
            >✍️</NuxtLink
          >
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
  const cache = useCache()

  onMounted(() => cache.loadDrills(true))

  const toggleActive = async (drillId, newValue) => {
    const resp = await $fetch(`/api/drill/${drillId}`, {
      method: 'PATCH',
      body: { is_active: newValue },
    })
    cache.updateDrill(JSON.parse(resp))
  }
</script>

<style lang="scss">
.drills-list {
  .table {
    display: table;
    text-align: left;
    margin: 1em auto;

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
      .active-icon {
        cursor: pointer;
        &:hover {
          opacity: 0.7;
        }
      }

      a.quiz-link {
        opacity: 0.6;
        text-decoration: none;

        &:hover {
          opacity: 1;
        }
      }
    }
  }
}
</style>
