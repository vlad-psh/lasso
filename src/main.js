window.Vue = require('vue');
require("jquery-ui/ui/widgets/autocomplete.js");
require("jquery-ujs");

require('./vue-radical.js');
require('./vue-kanji.js');
require('./vue-word.js');
require('./vue-search.js');

require('./vue-modal.js');
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
  const submitInterval = 30;

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
    if (s === submitInterval) {
      const submitUrl = `/api/activity/${typeof activityCategory !== "undefined" ? activityCategory : 'other'}/${submitInterval}`;
      fetch(submitUrl);
      s = 0;
    }
  }
}
activity();

// Mobile browsers proper height hack; Source: https://css-tricks.com/the-trick-to-viewport-units-on-mobile/
function correctVH() {
  // First we get the viewport height and we multiple it by 1% to get a value for a vh unit
  let vh = window.innerHeight * 0.01;
  // Then we set the value in the --vh custom property to the root of the document
  document.documentElement.style.setProperty('--vh', `${vh}px`);
};
correctVH();
window.addEventListener('resize', correctVH);

