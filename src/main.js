window.Vue = require('vue');
require("jquery-ui/ui/widgets/autocomplete.js");
require("jquery-ujs");

require('./vue-radical.js');
require('./vue-kanji.js');
require('./vue-word.js');

require('./vue-learn-buttons.js');
require('./vue-double-click-button.js');
require('./vue-editable-text.js');
require('./vue-dropdown.js');
require('./vue-sentence-form.js');
require('./vue-pitch-word.js');
require('./vue-pitch-word-nhk.js');
require('./vue-kanji-readings.js');
require('./vue-kanji-card.js');
require('./vue-settings-button.js');

/* ===================
   GLOBAL HOTKEYS
   =================== */
$(function(){
  $('.old-search-form input.search').on('keyup', function(event){
    if (event.which === 38 || event.which === 40) { // Up/Down keys
      var el = $('.old-search-form input[name=japanese]');
      el.prop('checked', el.is(':checked') ? false : true);
    }
  });
});

