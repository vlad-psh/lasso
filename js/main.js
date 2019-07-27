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

/* ===================
   GLOBAL HOTKEYS
   =================== */
$(document).on('keyup', function(event){
  if (event.which === 27) { // ESC
    $('#main-menu input.search').focus();
  }
});
$(function(){
  $('#main-menu input.search').on('keyup', function(event){
    if (event.which === 38 || event.which === 40) { // Up/Down keys
      var el = $('#main-menu input[name=japanese]');
      el.prop('checked', el.is(':checked') ? false : true);
    }
  });
});

/* ===================
   CLICK TO SHOW TITLE
   =================== */
$(document).on('click', '[title]', function(event){
  if ($('#title-tip').length) {
    $('#title-tip').remove();
  } else {
    var p = $(this).offset();
    var el = $( "<div id='title-tip'>" + $(this).attr("title") + "</div>" );
    $("body").append(el);

    var pleft = p.left + $(this).outerWidth()/2 - el.outerWidth()/2;
    var ptop = p.top + $(this).outerHeight() + 8;
    $("#title-tip").attr("style", "left: " + pleft + "px; top: " + ptop + "px");
  }
});
/* ===================
   SETTINGS
   =================== */
$(document).on('click', '.black-theme-checkbox', function(event){
  $.ajax({
    method: "POST",
    url: "/settings",
    data: {"black_theme": this.checked}
  });
  if (this.checked) {
    $('body').addClass("black");
  } else {
    $('body').removeClass("black");
  };
});
$(document).on('click', '.editing-checkbox input', function(event){
  $.ajax({
    method: "POST",
    url: "/settings",
    data: {"editing": this.checked}
  });
  if (typeof app !== "undefined") app.editing = this.checked;
});
/* ===================
   SPEECH
   =================== */
$(document).on('click', '.speech-link', function(event){
  if ($('#main-player').attr('src') != $(this).data('src')) {
    $('#main-player').attr('src', $(this).data('src'));
  }
  $('#main-player')[0].play();
});
