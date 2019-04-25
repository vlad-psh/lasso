window.Vue = require('vue');
require("jquery-ui/ui/widgets/autocomplete.js");
require("jquery-ujs");

require('./kanji.js');

/* ====================
   TOGGLE COMPACT CHECKBOX
   ==================== */
$(document).on('click', '.toggle-compact-form input', function(event){
  $('.toggle-compact-form').submit();
  $("div.elements-list-wrapper").toggleClass("elements-list-compact");
});
/* ====================
   HAMBURGER MENU
   ==================== */
$(document).on('mouseenter', '.hamburger', function(event){
  $("#overlay-menu").show();
});
$(document).on('mouseleave', '#overlay-menu', function(event){
  $("#overlay-menu").hide();
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
  $("#overlay-menu").hide();
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
