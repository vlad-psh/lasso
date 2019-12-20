Vue.component('vue-sentence-form', {
  props: {
    drillLists: {type: Object, required: false},
  },
  data() {
    return {
      jpSentence: null,
      enSentence: null,
      structure: [],
      editMode: false,
      selectedDrill: null,
      selection: {
        section: null, start: null, end: null,
        word: {base: null, gloss: null, reading: null, seq: null, text: null, index: null}
      }
    }
  },
  methods: {
    processRawSentence() {
      this.editMode = true;

      $.ajax({
        url: "/mecab",
        method: 'POST',
        data: {sentence: this.jpSentence}
      }).done(data => {
        this.structure = JSON.parse(data);
        this.resetSegment(null); // compact consecutive 'text' elements (without seq)
      });
    },
    textFragmentSelected() {
      var structureIndex = this.selection.section;
      var start  = Math.min(this.selection.start, this.selection.end);
      var finish = Math.max(this.selection.start, this.selection.end);

      var selectedText = this.structure[structureIndex].text.substring(start, finish);

      $.ajax({
        url: "/mecab",
        method: 'POST',
        data: {sentence: selectedText}
      }).done(data => {
        var jdata = JSON.parse(data);
        var result = [];
        var newSectionIndex = null;
        for (idx in this.structure) {
          var substr = this.structure[idx];
          if (idx == structureIndex) {
            if (start !== 0) result.push({text: substr.text.substring(0, start)});

            if (jdata.length === 1 && jdata[0].seq !== undefined) {
              jdata[0].text = jdata.reduce((acc,v) => acc + v.text, '');
              jdata[0].reading = jdata.reduce((acc,v) => acc + (v.reading || v.text), '');
              result.push(jdata[0]);
            } else {
              result.push({text: selectedText, seq: 0, reading: selectedText})
              newSectionIndex = result.length - 1;
            }

            if (substr.text.length > finish) result.push({text: substr.text.substring(finish, substr.text.length)});
          } else {
            result.push(substr);
          }
        }
        this.structure = result;
        this.selection.section = null; // reset selection
        this.resetSegment(null); // compact consecutive 'text' elements (without seq)
        if (newSectionIndex !== null) this.editWord(newSectionIndex); // open editor for current word
      });
    },
    resetSegment(partIdx) {
      var result = [];
      var tmpString = '';
      if (partIdx !== null) {
        delete this.structure[partIdx].seq; // also: reading, base, gloss
      }

      for (part of this.structure) {
        if (part.seq === undefined) {
          tmpString += part.text;
        } else {
          if (tmpString !== '') {
            result.push({text: tmpString});
            tmpString = '';
          }
          result.push(part);
        }
      }

      if (tmpString !== '') {
        result.push({text: tmpString});
        tmpString = '';
      }

      this.selection.word.index = null;
      this.structure = result;
    },
    clearProcessedSentence() {
      this.editMode = false;
      this.structure = [];
    },
    saveProcessedSentence() {
      $.ajax({
        url: "/sentences",
        method: 'POST',
        data: {
          japanese: this.jpSentence,
          english: this.enSentence,
          structure: this.structure,
          drill_id: this.selectedDrill}
      }).done(data => {
        //alert(data);
        this.jpSentence = null;
        //this.enSentence = null;
        this.structure = [];
        this.editMode = false;
      });
    },
    separatorClick(section, position) {
      if (this.selection.section === null || this.selection.section != section) {
        this.selection.section = section;
        this.selection.start = position;
      } else if (this.selection.start == position) {
        // reset selection if separator clicked twice
        this.selection.section = null;
      } else {
        this.selection.end = position;
        this.textFragmentSelected();
      }
    },
    editWord(section) {
      for (prop of ['base', 'gloss', 'reading', 'seq', 'text']) {
        this.selection.word[prop] = this.structure[section][prop];
      }
      this.selection.word.index = section;
    },
    updateWord() {
      var section = this.selection.word.index;
      for (prop of ['base', 'gloss', 'reading', 'seq', 'text']) {
        this.structure[section][prop] = this.selection.word[prop];
      }
      this.selection.word.index = null;
    }
  }, // end of methods
  updated() {
    var app = this;
    $('.word-settings input.search').autocomplete({
      source: "/api/word/autocomplete",
      minLength: 1,
      select: function(event, ui){
        app.selection.word.seq = ui.item.id;
        app.selection.word.gloss = ui.item.gloss;
        return false;
      },
      focus: function(event, ui){
        return false;
      }
    });
  },
  template: `
<div class="vue-sentence-form-app">
  <select v-model="selectedDrill">
    <option selected="selected"></option>
    <option v-for="d in drillLists" :value="d.id">{{d.title}}</option>
  </select>

  <table>
    <tr>
      <td>&#x1f1ef;&#x1f1f5;</td><!-- JP flag -->
      <td>

        <template v-if="editMode">

          <div class="sentence-composer">
            <template v-for="(section, sectionIndex) of structure">
              <template v-if="section.seq !== null && section.seq !== undefined">
                <div class="word" @click="editWord(sectionIndex)" @click.middle="resetSegment(sectionIndex)">
                  <div class="reading" v-if="section.reading">{{section.reading}}</div>
                  <div class="text">{{section.text}}</div>
                  <div class="gloss" v-if="section.gloss">{{section.gloss}}</div>
                  <div class="base" v-if="section.base">{{section.base}}</div>
                </div>
              </template>
              <template v-else>
                <div class="separator" @click="separatorClick(sectionIndex, 0)" :class="[selection.section == sectionIndex && selection.start == 0 ? 'selected' : null]"></div><template v-for="(char, charIndex) of section.text">
                  <div class="letter">{{char}}</div><div class="separator" @click="separatorClick(sectionIndex, charIndex + 1)" :class="[selection.section == sectionIndex && selection.start == charIndex + 1 ? 'selected' : null]"></div>
                </template>
              </template>
            </template>
          </div>

          <div v-if="selection.word.index !== null" class="word-settings">
            <div><input type="button" value="Clear" @click="resetSegment(selection.word.index)"></div>
            <div><input type="text" v-model="selection.word.reading" placeholder="reading"><br>{{selection.word.text}}</div>
            <div><input type="text" class="search" v-model="selection.word.base" placeholder="search..."><br>#{{selection.word.seq}} - {{selection.word.gloss}}</div>
            <div><input type="button" value="Update" @click="updateWord()"></div>
          </div>

        </template>

        <template v-else>
          <input class="jpsentence" type="text" v-model="jpSentence">
        </template>

      <td>
        <template v-if="editMode">
          <input type="button" value="Reset" @click="clearProcessedSentence">
        </template>
        <template v-else>
          <input type="button" value="Auto" @click="processRawSentence">
        </template>
      </td>
    </tr>
    <tr>
      <td>&#x1f1ec;&#x1f1e7;</td><!-- UK flag -->
      <td><input class="ensentence" type="text" v-model="enSentence"></td>
      <td>
        <input v-if="structure.length > 0" type="button" value="Save" @click="saveProcessedSentence">
      </td>
    </tr>
  </table>
</div>
`
});
