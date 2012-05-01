$(document).ready(function() {
  $('#body').keyup(function(){ furry.formatOnKeyUp($('#body'), $('.formatted-text-display')); });
  furry.formatOnKeyUp($('#body'), $('.formatted-text-display'));
});

furry = {}
furry.formatOnKeyUp = function(input, target) {
  $.ajax({
    url: '/get-formatted-text',
    type: 'get',
    data: { body: input.val() },
    success: function(msg) {
      target.html(msg);
    }
  });
};

furry.slugifyOnKeyUp = function(input, target) {
  $.ajax({
    url: '/get-slug',
    type: 'get',
    data: { string: input.val() },
    success: function(msg) {
      target.val(msg);
    }
  });
};
