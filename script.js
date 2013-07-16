var generateGrid = function(width, height) {
    // Clear grid before generating new one
    // TODO: add individual styling to grid depending on dimensions
    $grid = $('#shufflegrid');
    $grid.empty();

    for (var y=0; y<height; y++) {
        var $tr = $("<tr></tr>");
        $grid.append($tr);
        for (var x=0; x<width; x++) {
            var $cell = (x===width-1 && y===height-1) ? 
                    $('<td><div class="cell empty"></div></td>') : 
                    $('<td><div class="cell"><img src="images/Ammonite.gif"/></div></td>');
            $tr.append($cell);
        }
    }
};

$(document).ready(function() {

    // Setup initial grid
    generateGrid(3, 3);

    $('.cell').click(function() {
        /* TODO: check for not the empty cell, if necessary? */
        var $img = $(this).children('img');
        var $empty = $('.empty');
        $empty.append($img);
        $empty.removeClass('empty');
        $(this).addClass('empty');
    });
});
