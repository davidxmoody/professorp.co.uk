var SLIDING_DURATION = 100;

var currentLevel;

var tiles;
var tileHeight, tileWidth;

var generateGrid = function(width, height, columns, rows, emptyx, emptyy) {

    // Clear grid before generating new one
    $grid = $('#shufflegrid');
    $grid.empty();
    tiles = [];

    // Tile heights and widths include everything (border, padding, width)
    tileWidth = Math.floor(width/columns);
    tileHeight = Math.floor(height/rows);

    // The width and heigh parameters are the desired height and width only, 
    // actual height and width may vary to eliminate gaps.
    var gridWidth = tileWidth*columns;
    var gridHeight = tileHeight*rows;

    // Set the new dimensions of the grid
    $grid.css("width", gridWidth);
    $grid.css("height", gridHeight);

    // Check empty tile position is valid, if not use last tile
    if (emptyx<0 || emptyy<0 || emptyx>columns-1 || emptyy>rows-1) {
        emptyx = columns-1;
        emptyy = rows-1;
    }

    // Generate grid and tiles
    for (var y=0; y<rows; y++) {
        tiles[y] = [];
        for (var x=0; x<columns; x++) {
            if (x===emptyx && y===emptyy) {
                tiles[y][x] = null;  //TODO don't use null, use hidden tile instead
            } else {
                var $tile = $('<div class="tile"></div>');

                // Set tile position
                $tile.css("top", y*tileHeight);
                $tile.css("left", x*tileWidth);

                // Set tile dimensions (the -2 is for the 1px border/margin)
                $tile.css("width", tileWidth-2);
                $tile.css("height", tileHeight-2);

                // Set the "correct position" of the tile when checking if solved
                $tile.data("x", x);
                $tile.data("y", y);

                // Set the background image (clipped)
                $tile.css("background-image", "url(images/Ammonite.gif)");
                $tile.css("background-size", gridWidth+"px "+gridHeight+"px");
                $tile.css("background-repeat", "no-repeat");  //TODO is this necessary?
                $tile.css("background-position", (-1*tileWidth*x-1)+"px "+(-1*tileHeight*y-1)+"px");

                $grid.append($tile);
                tiles[y][x] = $tile;
            }
        }
    }

    // Setup triggers for clicking on tiles
    $('.tile').click(function() {
        tryMoveTile($(this));
    });

};

var tryMoveTile = function($tile) {
    if ($tile === null) return;

    // Get x and y positions of this tile and the empty tile
    for (var y=0; y<tiles.length; y++) {
        for (var x=0; x<tiles[0].length; x++) {
            if (tiles[y][x]===null) {
                var emptyx = x, emptyy = y;
            } else if (tiles[y][x].data("x")===$tile.data("x") && 
                       tiles[y][x].data("y")===$tile.data("y")) {
                var thisx = x, thisy = y;
            }
        }
    }

    var animation = null;
    // Check if tile is in a movable position
    if (thisx===emptyx && thisy-emptyy===1) {  // Move this tile up
        animation = { top: "-="+tileHeight };
    } else if (thisx===emptyx && thisy-emptyy===-1) {  // Move this tile down
        animation = { top: "+="+tileHeight };
    } else if (thisx-emptyx===1 && thisy===emptyy) {  // Move this tile left
        animation = { left: "-="+tileWidth };
    } else if (thisx-emptyx===-1 && thisy===emptyy) {  // Move this tile right
        animation = { left: "+="+tileWidth };
    }

    // Move the tile
    // TODO: make animation synchronous using callbacks
    if (animation !== null) {
        $tile.animate(animation, SLIDING_DURATION);
        tiles[emptyy][emptyx] = tiles[thisy][thisx];
        tiles[thisy][thisx] = null;
    }

    console.log(isSolved());
    return animation !== null;
}

var randomShuffle = function(numMoves) {
    // Randomly select any tile from the grid and try to move it, only continue if a tile was actually moved
    for (var i=0; i<numMoves;) {
        var randomTile = tiles[Math.floor(Math.random()*tiles.length)][Math.floor(Math.random()*tiles[0].length)];
        if (tryMoveTile(randomTile)) i++;
    }
}

var isSolved = function() {
    // For all tiles in the tiles array, check that their actual position matches their creation position
    //TODO prevent moving a tile back to where it was immediately before?
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
    generateGrid(300, 300, 3, 3, 2, 2);

    //TODO number of shuffles needs to be different depending on grid size
    randomShuffle(3);

});
