<template>
  <div class="vue-sentence-form-app">
    <table>
      <tr>
        <td><FlagJP class="svg-icon" /></td>
        <td>
          <template v-if="editMode">
            <div class="sentence-composer">
              <div
                v-for="(section, sectionIndex) of structure"
                :key="sectionIndex"
                class="section"
              >
                <template
                  v-if="section.seq !== null && section.seq !== undefined"
                >
                  <div
                    class="word"
                    @click="editWord(sectionIndex)"
                    @click.middle="resetSegment(sectionIndex)"
                  >
                    <div v-if="section.reading" class="reading">
                      {{ section.reading }}
                    </div>
                    <div class="text">{{ section.text }}</div>
                    <div v-if="section.gloss" class="gloss">
                      {{ section.gloss }}
                    </div>
                    <div v-if="section.base" class="base">
                      {{ section.base }}
                    </div>
                  </div>
                </template>
                <template v-else>
                  <div
                    :class="{
                      selected:
                        selection.section == sectionIndex &&
                        selection.start == 0,
                    }"
                    class="separator"
                    @click="separatorClick(sectionIndex, 0)"
                  ></div>
                  <div
                    v-for="(char, charIndex) of section.text"
                    :key="sectionIndex + '_' + charIndex"
                    class="letter"
                  >
                    {{ char }}
                    <div
                      :class="{
                        selected:
                          selection.section == sectionIndex &&
                          selection.start == charIndex + 1,
                      }"
                      class="separator"
                      @click="separatorClick(sectionIndex, charIndex + 1)"
                    ></div>
                  </div>
                </template>
              </div>
            </div>

            <div v-if="selection.word.index !== null" class="word-settings">
              <div>
                <input
                  type="button"
                  value="Clear"
                  @click="resetSegment(selection.word.index)"
                />
              </div>
              <div>
                <input
                  v-model="selection.word.reading"
                  type="text"
                  placeholder="Reading"
                /><br />{{ selection.word.text }}
              </div>
              <div>
                <input
                  type="button"
                  value="-"
                  @click="shrinkSelectedWord"
                /><input type="button" value="+" @click="stretchSelectedWord" />
              </div>
              <div style="width: 200px">
                <SentenceAutocompleteWord
                  placeholder="Search..."
                  @select="selectWord"
                  @search="searchWord"
                />
                #{{ selection.word.seq }}: {{ selection.word.base }}
                {{ selection.word.gloss }}
              </div>
              <div>
                <input type="button" value="Update" @click="updateWord()" />
              </div>
            </div>
          </template>

          <template v-else>
            <input v-model="jpSentence" class="jpsentence" type="text" />
          </template>
        </td>

        <td>
          <template v-if="editMode">
            <input
              type="button"
              value="Reset"
              @click="clearProcessedSentence"
            />
          </template>
          <template v-else>
            <input type="button" value="Auto" @click="processRawSentence" />
          </template>
        </td>
      </tr>
      <tr>
        <td><FlagUK class="svg-icon" /></td>
        <td><input v-model="enSentence" class="ensentence" type="text" /></td>
        <td>
          <input
            v-if="structure.length > 0"
            type="button"
            value="Save"
            @click="saveProcessedSentence"
          />
        </td>
      </tr>
    </table>
  </div>
</template>

<script setup>
  import FlagJP from '../../assets/icons/flag-jp.svg'
  import FlagUK from '../../assets/icons/flag-uk.svg'

  const props = defineProps({
    drillId: { type: Number, required: true },
  })

  const jpSentence = ref()
  const enSentence = ref()
  const structure = ref([])
  const editMode = ref(false)
  const selection = reactive({
    section: null,
    start: null,
    end: null,
    word: {
      base: null,
      gloss: null,
      reading: null,
      seq: null,
      text: null,
      index: null,
    },
  })

  const selectWord = (item, kreb) => {
    selection.word.seq = item.seq
    selection.word.gloss = item.gloss
    selection.word.base = kreb
  }

  const searchWord = async (query, cb) => {
    const resp = await $fetch('/api/autocomplete/word', { method: 'POST', body: { query } })
    console.log('got response', resp)
    cb(JSON.parse(resp))
  }

  const processRawSentence = async () => {
    editMode.value = true

    const resp = await $fetch('/api/mecab/text', {
      method: 'POST',
      body: { sentence: jpSentence.value },
    })
    structure.value = JSON.parse(resp)
    resetSegment(null) // compact consecutive 'text' elements (without seq)
  }

  const textFragmentSelected = async () => {
    const structureIndex = selection.section
    const start = Math.min(selection.start, selection.end)
    const finish = Math.max(selection.start, selection.end)

    const selectedText = structure.value[structureIndex].text.substring(
      start,
      finish
    )

    const resp = await $fetch('/api/mecab/text', {
      method: 'POST',
      body: { sentence: selectedText },
    })
    const jdata = JSON.parse(resp)
    const result = []
    let newSectionIndex = null
    for (let idx = 0; idx < structure.value.length; idx++) {
      const substr = structure.value[idx]
      if (idx === structureIndex) {
        if (start !== 0)
          result.push({ text: substr.text.substring(0, start) })

        if (jdata.length === 1 && jdata[0].seq !== undefined) {
          jdata[0].text = jdata.reduce((acc, v) => acc + v.text, '')
          jdata[0].reading = jdata.reduce(
            (acc, v) => acc + (v.reading || v.text),
            ''
          )
          result.push(jdata[0])
        } else {
          result.push({ text: selectedText, seq: 0, reading: selectedText })
          newSectionIndex = result.length - 1
        }

        if (substr.text.length > finish)
          result.push({
            text: substr.text.substring(finish, substr.text.length),
          })
      } else {
        result.push(substr)
      }
    }
    structure.value = result
    selection.section = null // reset selection
    resetSegment(null) // compact consecutive 'text' elements (without seq)
    if (newSectionIndex !== null) editWord(newSectionIndex) // open editor for current word
  }

  const resetSegment = (partIdx) => {
    const result = []
    let tmpString = ''
    if (partIdx !== null) {
      delete structure.value[partIdx].seq // also: reading, base, gloss
    }

    for (const part of structure.value) {
      if (part.seq === undefined) {
        tmpString += part.text
      } else {
        if (tmpString !== '') {
          result.push({ text: tmpString })
          tmpString = ''
        }
        result.push(part)
      }
    }

    if (tmpString !== '') {
      result.push({ text: tmpString })
      tmpString = ''
    }

    selection.word.index = null
    structure.value = result
  }

  const clearProcessedSentence = () => {
    editMode.value = false
    structure.value = []
  }

  const saveProcessedSentence = async () => {
    await $fetch('/api/sentences', {
      method: 'POST',
      body: {
        japanese: jpSentence.value,
        english: enSentence.value,
        structure: structure.value,
        drill_id: props.drillId,
      },
    })

    // alert(data);
    jpSentence.value = null
    // enSentence.value = null;
    structure.value = []
    editMode.value = false
  }

  const separatorClick = (section, position) => {
    if (
      selection.section === null ||
      selection.section !== section
    ) {
      selection.section = section
      selection.start = position
    } else if (selection.start === position) {
      // reset selection if separator clicked twice
      selection.section = null
    } else {
      selection.end = position
      textFragmentSelected()
    }
  }

  const editWord = (section) => {
    for (const prop of ['base', 'gloss', 'reading', 'seq', 'text']) {
      selection.word[prop] = structure.value[section][prop]
    }
    selection.word.index = section
  }

  const updateWord = () => {
    const section = selection.word.index
    for (const prop of ['base', 'gloss', 'reading', 'seq', 'text']) {
      structure.value[section][prop] = selection.word[prop]
    }
    selection.word.index = null
  }

  const stretchSelectedWord = () => {
    const idx = selection.word.index
    const nextWord = structure.value[idx + 1]
    // return if this is the last word in sentence or if next word is a word object (not a simple text)
    if (!nextWord || nextWord.seq || nextWord.text.length === 0) return
    structure.value[idx].reading += nextWord.text[0]
    structure.value[idx].text += nextWord.text[0]
    nextWord.text = nextWord.text.substr(1) // cut first letter
    editWord(idx)
  }

  const shrinkSelectedWord = () => {
    const idx = selection.word.index
    const nextWord = structure.value[idx + 1]
    if (!nextWord || nextWord.seq) return
    nextWord.text = structure.value[idx].text.substr(-1) + nextWord.text
    structure.value[idx].reading = structure.value[idx].reading.slice(0, -1)
    structure.value[idx].text = structure.value[idx].text.slice(0, -1)
    editWord(idx)
  }
</script>

<style lang="scss">
.sentence-composer {
  font-size: 2em;
  line-height: 1.2em;
  // @include non-selectable;

  .section {
    display: inline-block;
  }
  .word {
    display: inline-block;
    user-select: none;
    cursor: default;
    vertical-align: middle;
    background-color: #eee;
    margin: 0 1.5px;
    z-index: 10; // hover/click priority over separators
    position: relative;
    cursor: cell;
    line-height: initial;

    .reading {
      font-size: small;
    }
    .gloss {
      font-size: xx-small;
    }
    .base {
      font-size: x-small;
    }
  }
  .letter {
    display: inline-block;
    user-select: none;
    cursor: default;
    vertical-align: middle;
  }
  .separator {
    display: inline-block;
    position: relative; /* prevents blinking */
    vertical-align: middle;
    font-size: 1.5em;
    cursor: pointer;
    color: #eee;
    width: 1em;
    margin: 0 -0.45em;
    padding: 0.2em 0;

    &:after {
      content: '\22ee'; /* 25b2 -> 2e3d */
    }
    &:hover {
      color: #26a5cc;
    }
    &.selected {
      color: red;
    }
  }
} /* end of sentence-composer */

.word-settings {
  display: flex;
  justify-content: space-evenly;
  background-color: #eee;
  padding: 0.5em 0;
  margin: 0.5em 0;

  .label {
    font-size: 0.7em;
    opacity: 0.5;
  }
  input[type='text'] {
    width: 8em;
  }
  input {
    font-weight: normal;
    min-width: 2em;
  }
}

.vue-sentence-form-app {
  table td:nth-child(2) {
    width: 100%;
  }
  input.jpsentence,
  input.ensentence {
    font-size: 1.2em;
    width: calc(100% - 0.8em);
    max-width: 40em;
    padding: 0.2em 0.4em;
    border: none;
    border-bottom: 2px solid rgba(0, 0, 0, 0.1);
    background: none;
  }
}
</style>
