$(document).ready(function() {
  $('#body').keyup(function(){
    furry.formatOnKeyUp();
  });
  furry.formatOnKeyUp();
});

furry = {}
furry.formatOnKeyUp = function() {
  $.ajax({
    url: '/get-formatted-text',
    type: 'post',
    data: { body: $('#body').val() },
    success: function(msg) {
      $('.formatted-text-display').html(msg);
    }
  });
};
