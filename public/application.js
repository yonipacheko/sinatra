/**
 * Created with JetBrains RubyMine.
 * User: yoniPacheko
 * Date: 2013-08-02
 * Time: 10:56
 * To change this template use File | Settings | File Templates.
 */
$(document).ready(function(){
  $('.main-btns').on('click', '#hit_me', hit_me);

  $('.main-btns').on('click', '#stay_me', stay_me);


});


function hit_me() {
    alert('click on hit');
    $.ajax({
        type: 'POST',
        url: '/game/player/hit'})
        .done(function (respons) {
            $('#game').replaceWith(respons)
        });


    return false;
}


function stay_me() {
    alert('click on stay');
    $.ajax({
        type: 'POST',
        url: '/game/player/stay'})
        .done(function (respons) {
            $('#game').replaceWith(respons)
        });


    return false;
}


