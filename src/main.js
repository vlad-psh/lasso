window.Vue = require('vue');
require("jquery-ui/ui/widgets/autocomplete.js");
require("jquery-ujs");

require('./vue-radical.js');
require('./vue-kanji.js');
require('./vue-word.js');
require('./vue-search.js');

require('./vue-learn-buttons.js');
require('./vue-double-click-button.js');
require('./vue-editable-text.js');
require('./vue-dropdown.js');
require('./vue-sentence-form.js');
require('./vue-pitch-word.js');
require('./vue-pitch-word-nhk.js');
require('./vue-settings-button.js');

function activeSecondsAdd() {
  activeSeconds += 1;
  if (activeSeconds === 5) {
    fetch('/api/activity/5');
    activeSeconds = 0;
    if (!document.hasFocus) activeInterval = window.clearInterval(activeInterval);
  }
}
var activeSeconds = 0;
var activeInterval = window.setInterval(activeSecondsAdd, 1000);
document.onfocus = () => {if (!activeInterval) activeInterval = window.setInterval(activeSecondsAdd, 1000)};
document.onblur = () => activeInterval = window.clearInterval(activeInterval);
