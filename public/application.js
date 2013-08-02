/**
 * Created with JetBrains RubyMine.
 * User: yoniPacheko
 * Date: 2013-08-02
 * Time: 10:56
 * To change this template use File | Settings | File Templates.
 */
$(document).ready(function(){

  $(this).on('click', '#hit_me', hit_me);
 // hit_me();
  $(this).on('click', '#stay_me', stay_me);

  $(this).on('click', '#next_card', dealer_hit_me);

});


function hit_me() {
    //$(document).on("click", 'form #hit_me', function() {

       // alert('click on hit');
    $.ajax({
        type: 'POST',
        url: '/game/player/hit'})
        .done(function(respons) {
            $('#game').replaceWith(respons)


        });

   // });
        return false;

}


function stay_me() {
   // alert('click on stay');
    $.ajax({
        type: 'POST',
        url: '/game/player/stay'})
        .done(function(respons) {
            $('#game').replaceWith(respons)

        });


    return false;
}

function dealer_hit_me(){
   // alert("dealer hits!");
    $.ajax({
        type: 'POST',
        url: '/game/dealer/next_card'
    }).done(function(msg){
            $("div#game").replaceWith(msg);
        });
    return false;
}

