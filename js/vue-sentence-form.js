Vue.component('vue-sentence-form', {
  data() {
    return {
      rawSentence: '',
      jpSentence: null,
      enSentence: null,
      structure: [],
      editMode: false
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
        this.newSentenceResetPart(null); // compact consecutive 'text' elements (without seq)
      });
    },
    newSentencePartSelected(structureIndex, start, finish) {
      var selectedText = this.structure[structureIndex].text.substring(start, finish);
      //console.log('newSentencePartSelected()');
      //console.log('structure[' + structureIndex + '] = ' + JSON.stringify(this.structure[structureIndex]));
      //console.log('(' + start + '..' + finish + ') = ' + selectedText);

      $.ajax({
        url: "/mecab",
        method: 'POST',
        data: {sentence: selectedText}
      }).done(data => {
        var jdata = JSON.parse(data);
        var result = [];
        for (idx in this.structure) {
          var substr = this.structure[idx];
          if (idx == structureIndex) {
            if (start !== 0) result.push({text: substr.text.substring(0, start)});

            jdata[0].text = jdata.reduce((acc,v) => acc + v.text, '');
            jdata[0].reading = jdata.reduce((acc,v) => acc + (v.reading || v.text), '');
            result.push(jdata[0]);

            if (substr.text.length > finish) result.push({text: substr.text.substring(finish, substr.text.length)});
          } else {
            result.push(substr);
          }
        }
        //textarea.selectionStart = textarea.selectionEnd = 0;
        // TODO: reset selection
        this.structure = result;
        this.newSentenceResetPart(null); // compact consecutive 'text' elements (without seq)
      });
    },
    newSentenceResetPart(partIdx) {
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
          structure: this.structure}
      }).done(data => {
        alert(data);
        this.jpSentence = null;
        this.enSentence = null;
        this.newSentence = [];
      });
    }
  }, // end of methods
  beforeMount() {
    var app = this;
    document.onmouseup = function() {
      if (window.getSelection) {
        var selection = window.getSelection();
        if (selection.anchorNode && selection.toString() !== '' &&
            $('.new-sentence').has(selection.anchorNode.parentNode).length > 0) {
          app.newSentencePartSelected(
                Number.parseInt(selection.anchorNode.parentNode.getAttribute('data-structure-index')),
                selection.anchorOffset, selection.focusOffset);
        }
      } else if (document.selection && document.selection.type != "Control") {
        console.log('unsupported method');
        //text = document.selection.createRange().text;
      }
    };
  },
  template: `
<div class="vue-sentence-form-app">
  <table>
    <tr>
      <td>&#x1f1ef;&#x1f1f5;</td>
      <td>

        <template v-if="editMode">
          <div class='new-sentence' @select="console.log('select')">
            <ruby v-for="(substr, sIdx) of structure" @click="newSentenceResetPart(sIdx)" :class='substr.seq ? "question-word" : ""'>
              <rb :data-structure-index="sIdx">{{substr.text}}</rb>
              <rt v-if="substr.reading">{{substr.reading}}</rt>
              <rtc v-if="substr.gloss">{{substr.gloss}}</rtc>
            </ruby>
          </div>
        </template>

        <template v-else>
          <input class="jpsentence" type="text" @select="newSentencePartSelected" v-model="jpSentence">
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
      <td>&#x1f1ec;&#x1f1e7;</td>
      <td><input class="ensentence" type="text" v-model="enSentence"></td>
    </tr>
  </table>

  <input v-if="structure.length > 0" type="button" value="save" @click="saveProcessedSentence">
</div>
`
});
