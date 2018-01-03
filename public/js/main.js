/* ====================
   AJAX FORM
   ==================== */
$(document).on('click', '.custom-note', function(event){
  $(this).hide();
  $('#' + $(this).data('id') + ' .add-note-form').show();
  $('#' + $(this).data('id') + ' .add-note-form textarea').focus();
});

$(document).on('ajax:success', '.add-note-form', function(xhr, data, status){
  var id = $(this).data('id')
  $('#' + id + ' .custom-note').html(data).show();
  $(this).hide();
});

$(document).on('ajax:error', '.add-note-form', function(){
  alert('Error occurred');
});

$(document).on('keyup', 'textarea,input', function(e){
  e.stopPropagation();
});
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
/* ====================
   BB CODE FORMAT BUTTONS
   ==================== */
$(document).on('click', '.bb-format-link', function(event){
  var textarea = $(this).parent().find('textarea')[0];
  var text = textarea.value;
  var tag = $(this).data('tag');
  var newText;

  newText = text.substring(0, textarea.selectionStart) + '[' + tag + ']'
            + text.substring(textarea.selectionStart, textarea.selectionEnd)
            + '[/' + tag + ']' + text.substr(textarea.selectionEnd);
  textarea.value = newText;
  textarea.focus();
});
