$(document).ready(function() {
    $('.cell').click(function() {
        /* TODO: check for not the empty cell, if necessary? */
        var $img = $(this).children('img');
        var $empty = $('.empty');
        $empty.append($img);
        $empty.removeClass('empty');
        $(this).addClass('empty');
    });
});
