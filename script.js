var SLIDING_DURATION = 50;
var COMPLETED_FADE_IN_DURATION = 2000;
var INITIAL_SHUFFLE_DELAY = 200;

var allowInput = false;

var tiles;
var tileHeight, tileWidth;
var gridHeight, gridWidth;

var currentLevel;
var currentLevelIndex = -1;

var LEVELS = [
      { name: "Ammonite", image: "images/ammonite.gif", aspectRatio: 1, 
        difficulty: 0.3, gridSize: [3, 3], emptyTile: [2, 2] },
      { name: "Shark Teeth", image: "images/shark-teeth.gif", aspectRatio: 1, 
        difficulty: 0.5, gridSize: [3, 4], emptyTile: [2, 3] },
      { name: "Ammonite Shell", image: "images/ammonite-shell.gif", aspectRatio: 1, 
        difficulty: 0.7, gridSize: [4, 4], emptyTile: [3, 3] }
    ];
                


var generateGrid = function(width, height, columns, rows, emptyx, emptyy, image) {

    // Clear grid before generating new one
    $grid = $('#shufflegrid');
    $grid.empty();
    tiles = [];

    // Tile heights and widths include everything (border, padding, width)
    tileWidth = Math.floor(width/columns);
    tileHeight = Math.floor(height/rows);

    // The width and heigh parameters are the desired height and width only, 
    // actual height and width may vary to eliminate gaps.
    gridWidth = tileWidth*columns;
    gridHeight = tileHeight*rows;

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
                $tile.css("background-image", "url("+image+")");
                $tile.css("background-size", gridWidth+"px "+gridHeight+"px");
                $tile.css("background-position", (-1*tileWidth*x-1)+"px "+(-1*tileHeight*y-1)+"px");

                $grid.append($tile);
                tiles[y][x] = $tile;
            }
        }
    }

    // Setup triggers for clicking on tiles
    $('.tile').click(function() {
        if (!allowInput) return;
        allowInput = false;
        tryMoveTile($(this), function() { 
            allowInput = true; 
            if (isSolved()) {
                levelComplete();
            }
        });
    });

};

var tryMoveTile = function($tile, callback) {
    if ($tile === null) {
        callback(false);
        return;
    }

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

    // Move the tile, then swap tiles in the array and then call the callback function with the success value
    if (animation !== null) {
        $tile.animate(animation, SLIDING_DURATION, function() {
            tiles[emptyy][emptyx] = tiles[thisy][thisx];
            tiles[thisy][thisx] = null;
            callback(true);
        });
    } else {
        callback(false);
    }
}

var randomShuffle = function(lastTile) {
    // Disable user input while shuffling, reenable when finished
    allowInput = false;

    // Keep shuffling until almost every tile has been moved away from it's original position
    if (numNotCorrect()>=tiles[0].length*tiles.length-2) {
        allowInput = true;
        return;
    }

    // Randomly select any tile from the grid and try to move it, try again if tile was not moved
    var randomTile;
    do {
        randomTile = tiles[Math.floor(Math.random()*tiles.length)][Math.floor(Math.random()*tiles[0].length)];
    } while (lastTile !== null && randomTile === lastTile);

    tryMoveTile(randomTile, function(moved) {
        randomShuffle(moved ? randomTile : lastTile);
    });
}

var numNotCorrect = function() {
    // For all tiles in the tiles array, check that their actual position matches their creation position
    //TODO prevent moving a tile back to where it was immediately before?
    var count = 0;
    for (var y=0; y<tiles.length; y++) {
        for (var x=0; x<tiles[0].length; x++) {
            if (tiles[y][x] !== null && (tiles[y][x].data("x") !== x || tiles[y][x].data("y") !== y)) 
                count++;
        }
    }
    return count;
}

var isSolved = function() {
    return numNotCorrect()===0;
}

var levelComplete = function() {
    allowInput = false;
    $img = $('<img style="height: 100%; width: 100%;" src="'+currentLevel.image+'"/>');
    $img.fadeIn(COMPLETED_FADE_IN_DURATION, function() {
        $("#shufflegrid").click(function() {
            $(this).off("click");
            loadNextLevel();
        });
    });
    $grid.prepend($img);
}

var loadLevel = function(level) {
    console.log("Loading level: "+level.name+" "+level.gridSize[0]+"x"+level.gridSize[1]);
    currentLevel = level;
    generateGrid(400, 400, level.gridSize[0], level.gridSize[1], 
                 level.emptyTile[0], level.emptyTile[1], level.image);
    window.setTimeout(function() { randomShuffle(null); }, 2000);
}

var loadNextLevel = function() {
    if (currentLevelIndex+1>=LEVELS.length) return;  // No more levels available
    currentLevelIndex++;
    loadLevel(LEVELS[currentLevelIndex]);
}

$(document).ready(function() {

    loadNextLevel();

});
