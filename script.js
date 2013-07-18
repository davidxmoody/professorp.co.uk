var SLIDING_DURATION = 100;
var TILE_WIDTH = 202;
var tiles;

var generateGrid = function(width, height) {
    // Clear grid before generating new one
    // TODO: add individual styling to grid/tiles depending on dimensions
    $grid = $('#shufflegrid');
    $grid.empty();
    tiles = [];

    // Generate grid and tiles
    for (var y=0; y<height; y++) {
        tiles[y] = [];
        for (var x=0; x<width; x++) {
            if (x===width-1 && y===height-1) {  // if this is the final cell
                tiles[y][x] = null;  //TODO don't use null, use hidden tile instead
            } else {
                var $tile = $('<div class="tile" style="margin-top: '+y*TILE_WIDTH+'px; margin-left: '+x*TILE_WIDTH+'px;"><p>'+x+','+y+'</p></div>');
                $tile.data("x", x);
                $tile.data("y", y);
                $grid.append($tile);
                tiles[y][x] = $tile;
            }
        }
    }

    // Setup triggers for clicking on tiles
    $('.tile').click(function() {
        // Get x and y positions of this tile and the empty tile
        for (var y=0; y<tiles.length; y++) {
            for (var x=0; x<tiles[0].length; x++) {
                if (tiles[y][x]===null) {
                    var emptyx = x, emptyy = y;
                } else if (tiles[y][x].data("x")===$(this).data("x") && 
                           tiles[y][x].data("y")===$(this).data("y")) {
                    var thisx = x, thisy = y;
                }
            }
        }

        var animation = null;
        // Check if tile is in a movable position
        if (thisx===emptyx && thisy-emptyy===1) {  // Move this tile up
            animation = { top: "-="+TILE_WIDTH };
        } else if (thisx===emptyx && thisy-emptyy===-1) {  // Move this tile down
            animation = { top: "+="+TILE_WIDTH };
        } else if (thisx-emptyx===1 && thisy===emptyy) {  // Move this tile left
            animation = { left: "-="+TILE_WIDTH };
        } else if (thisx-emptyx===-1 && thisy===emptyy) {  // Move this tile right
            animation = { left: "+="+TILE_WIDTH };
        }

        // Move the tile
        // TODO: make animation synchronous using callbacks
        if (animation !== null) {
            $(this).animate(animation, SLIDING_DURATION);
            tiles[emptyy][emptyx] = tiles[thisy][thisx];
            tiles[thisy][thisx] = null;
        }

        if (isSolved()) alert("You did it!");
            
    });

};

var isSolved = function() {
    for (var y=0; y<tiles.length; y++) {
        for (var x=0; x<tiles[0].length; x++) {
            if (tiles[y][x] !== null && (tiles[y][x].data("x") !== x || tiles[y][x].data("y") !== y)) 
                return false;
        }
    }
    return true;
}

$(document).ready(function() {

    // Setup initial grid
    generateGrid(3, 3);

});
