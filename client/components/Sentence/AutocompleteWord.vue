<template>
  <div class="autocomplete" :class="{ expanded }">
    <input
      type="text"
      @input="inputChanged"
      @click="expanded = true"
      @keydown.esc="expanded = false"
    />
    <div v-show="expanded" class="candidates-list">
      <li v-for="(candidate, idx) of candidates" :key="'candidate' + idx">
        <div class="title">{{ candidate.seq }}: {{ candidate.gloss }}</div>
        <div class="krebs">
          <div
            v-for="kreb of candidate.krebs"
            :key="'seq' + candidate.seq + 'kreb' + kreb"
            class="kreb"
            @click="candidateSelected(candidate, kreb)"
          >
            {{ kreb }}
          </div>
        </div>
      </li>
    </div>
  </div>
</template>

<script setup>
  defineProps({
    placeholder: { type: String, default: 'Search...' },
  })

  const inputValue = ref()
  const candidates = ref([])
  const expanded = ref(false)

  const emit = defineEmits(['search', 'select'])

  const inputChanged = (el) => {
    emit('search', el.target.value, (x) => {
      candidates.value = x || []
      expanded.value = true
    })
  }

  const candidateSelected = (item, kreb) => {
    expanded.value = false
    emit('select', item, kreb)
  }
</script>

<style lang="scss" scoped>
.autocomplete {
  position: relative;
  text-align: left;
  font-size: 0.9em;

  input[type='text'],
  .candidates-list {
    box-sizing: border-box;
    border: 1px solid #7777;
    width: 100%;
  }

  input[type='text'] {
    padding: 0.3em 0.7em;
    width: 100%;
    border-radius: 3px;

    &:focus {
      outline: none;
      border: 1px solid #38c7cc;
      box-shadow: 0 0 1px 1px #38c7cc;
    }
  }
  &.expanded input[type='text'] {
    border-bottom-left-radius: 0;
    border-bottom-right-radius: 0;
  }

  .candidates-list {
    position: absolute;
    background: white;
    max-height: 15em;
    overflow-y: auto;
    border-bottom-left-radius: 3px;
    border-bottom-right-radius: 3px;
    margin-top: -1px;

    li {
      list-style: none;
      cursor: pointer;

      .title {
        font-size: 0.8em;
        opacity: 0.7;
        margin-left: 0.6em;
      }
      .krebs {
        display: flex;
        flex-flow: column;
        margin-top: 0.2em;

        .kreb {
          padding: 0.2em 0 0.2em 1.5em;

          &:hover {
            background: #41b883;
            color: white;
          }
        }
      }
    }

    li + li {
      padding-top: 0.5em;
    }
  }
}
</style>
