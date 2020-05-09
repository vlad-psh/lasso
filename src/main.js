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

function activity() {
  var s = 0;
  var active; // active interval
  var idle; // idle timeout
  var idleTS = new Date() - 5000;
  ['load', 'mousedown', 'mousemove', 'keydown', 'scroll', 'touchstart'].forEach(function(name) {
    window.addEventListener(name, start, true);
  });
  document.addEventListener("visibilitychange", function() {
    if (document.visibilityState === 'visible') start();
  });

  function start() {
    if (!active) {
      active = setInterval(tick, 1000);
    }
    if (new Date() - idleTS > 1000) {
      idleTS = new Date();
      clearTimeout(idle);
      idle = setTimeout(stop, 5000);
    }
  }
  function stop() {
    clearInterval(active);
    active = null;
  }
  function tick() {
    s += 1;
    if (s === 30) {
      fetch('/api/activity/search/30');
      s = 0;
    }
  }
}
activity();

