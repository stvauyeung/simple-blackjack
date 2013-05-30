$(document).ready(function(){

  $("form#hit_form button").click(function(){
    $.ajax({
      type: 'POST',
      url: '/game/player/hit'
    }).done(function(msg) {
      $("#game").replaceWith(msg);
    });
  return false;
  });

});