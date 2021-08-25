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

<script>
import FlagJP from '@/assets/icons/flag-jp.svg?inline'
import FlagUK from '@/assets/icons/flag-uk.svg?inline'

export default {
  components: { FlagJP, FlagUK },
  props: {
    drillId: { type: Number, required: true },
  },
  data() {
    return {
      jpSentence: null,
      enSentence: null,
      structure: [],
      editMode: false,
      selection: {
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
      },
    }
  }, // end of methods
  methods: {
    selectWord(item, kreb) {
      this.selection.word.seq = item.seq
      this.selection.word.gloss = item.gloss
      this.selection.word.base = kreb
    },
    async searchWord(query, cb) {
      const resp = await this.$axios.post('/api/autocomplete/word', { query })
      cb(resp.data)
    },
    async processRawSentence() {
      this.editMode = true

      const resp = await this.$axios.post('/api/mecab/text', {
        sentence: this.jpSentence,
      })
      this.structure = resp.data
      this.resetSegment(null) // compact consecutive 'text' elements (without seq)
    },
    async textFragmentSelected() {
      const structureIndex = this.selection.section
      const start = Math.min(this.selection.start, this.selection.end)
      const finish = Math.max(this.selection.start, this.selection.end)

      const selectedText = this.structure[structureIndex].text.substring(
        start,
        finish
      )

      const resp = await this.$axios.post('/api/mecab/text', {
        sentence: selectedText,
      })
      const jdata = resp.data
      const result = []
      let newSectionIndex = null
      for (let idx = 0; idx < this.structure.length; idx++) {
        const substr = this.structure[idx]
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
      this.structure = result
      this.selection.section = null // reset selection
      this.resetSegment(null) // compact consecutive 'text' elements (without seq)
      if (newSectionIndex !== null) this.editWord(newSectionIndex) // open editor for current word
    },
    resetSegment(partIdx) {
      const result = []
      let tmpString = ''
      if (partIdx !== null) {
        delete this.structure[partIdx].seq // also: reading, base, gloss
      }

      for (const part of this.structure) {
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

      this.selection.word.index = null
      this.structure = result
    },
    clearProcessedSentence() {
      this.editMode = false
      this.structure = []
    },
    async saveProcessedSentence() {
      await this.$axios.post('/api/sentences', {
        japanese: this.jpSentence,
        english: this.enSentence,
        structure: this.structure,
        drill_id: this.drillId,
      })

      // alert(data);
      this.jpSentence = null
      // this.enSentence = null;
      this.structure = []
      this.editMode = false
    },
    separatorClick(section, position) {
      if (
        this.selection.section === null ||
        this.selection.section !== section
      ) {
        this.selection.section = section
        this.selection.start = position
      } else if (this.selection.start === position) {
        // reset selection if separator clicked twice
        this.selection.section = null
      } else {
        this.selection.end = position
        this.textFragmentSelected()
      }
    },
    editWord(section) {
      for (const prop of ['base', 'gloss', 'reading', 'seq', 'text']) {
        this.selection.word[prop] = this.structure[section][prop]
      }
      this.selection.word.index = section
    },
    updateWord() {
      const section = this.selection.word.index
      for (const prop of ['base', 'gloss', 'reading', 'seq', 'text']) {
        this.structure[section][prop] = this.selection.word[prop]
      }
      this.selection.word.index = null
    },
    stretchSelectedWord() {
      const idx = this.selection.word.index
      const nextWord = this.structure[idx + 1]
      // return if this is the last word in sentence or if next word is a word object (not a simple text)
      if (!nextWord || nextWord.seq || nextWord.text.length === 0) return
      this.structure[idx].reading += nextWord.text[0]
      this.structure[idx].text += nextWord.text[0]
      nextWord.text = nextWord.text.substr(1) // cut first letter
      this.editWord(idx)
    },
    shrinkSelectedWord() {
      const idx = this.selection.word.index
      const nextWord = this.structure[idx + 1]
      if (!nextWord || nextWord.seq) return
      nextWord.text = this.structure[idx].text.substr(-1) + nextWord.text
      this.structure[idx].reading = this.structure[idx].reading.slice(0, -1)
      this.structure[idx].text = this.structure[idx].text.slice(0, -1)
      this.editWord(idx)
    },
  },
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
