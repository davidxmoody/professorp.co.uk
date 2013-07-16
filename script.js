var tiles = [];
var cells = [];

var generateGrid = function(width, height) {
    // Clear grid before generating new one
    // TODO: add individual styling to grid depending on dimensions
    $grid = $('#shufflegrid');
    $grid.empty();
    tiles = [];
    cells = [];

    for (var y=0; y<height; y++) {
        var $tr = $("<tr></tr>");
        $grid.append($tr);
        for (var x=0; x<width; x++) {
            var $cell = $('<td class="cell"></td>');
            if (x===width-1 && y===height-1) {  // if this is the final cell
                $cell.addClass('empty');
            } else {
                var $tile = $('<div class="tile"><p>'+x+','+y+'</p></div>');
                $cell.append($tile);
                tiles.push($tile);
            }
            $tr.append($cell);
            cells.push($cell);
        }
    }
};

var checkSolved = function() {
    for (var i=0; i<tiles.length; i++) 
        if (cells[i].has(tiles[i]).length!==1) return false;
    return true;
}

$(document).ready(function() {

    // Setup initial grid
    generateGrid(3, 3);

    $('.cell').click(function() {
        var $tile = $(this).children('.tile');
        var $empty = $('.empty');
        $empty.append($tile);
        $empty.removeClass('empty');
        $(this).addClass('empty');
        console.log(checkSolved());
    });
});
