var SLIDING_DURATION = 50;
var COMPLETED_FADE_IN_DURATION = 2000;
var INITIAL_SHUFFLE_DELAY = 200;

var LEVELS = [
  { name: "Ammonite", image: "images/ammonite.gif",
    gridSize: [3, 3], emptyTile: [2, 2] },
  { name: "Shark Teeth", image: "images/shark-teeth.gif",
    gridSize: [3, 4], emptyTile: [2, 3] },
  { name: "Ammonite Shell", image: "images/ammonite-shell.gif",
    gridSize: [4, 4], emptyTile: [3, 3] }
];


/* First create a grid from level data and maximum dimensions and tell it where to put itself
   Then shuffle the grid and start the game
   Give it a callback function to be called when the game is completed
   Finally destroy it once you are done with it and want to load another one */


function ShuffleGrid(level, $container, maxWidth, maxHeight) {

    // Disable user input until level has been started
    this.allowInput = false;

    // Tile heights and widths include everything (border, padding, width)
    this.tileWidth = Math.floor(maxWidth/level.gridSize[0]);
    this.tileHeight = Math.floor(maxWidth/level.gridSize[1]);

    // Actual grid size depends on the number of tiles across and the tile size
    var gridWidth = this.tileWidth*level.gridSize[0];
    var gridHeight = this.tileHeight*level.gridSize[1];

    // Create the actual grid and set dimensions/style
    this.$grid = $("<div/>");
    this.$grid.css("position", "relative");
    this.$grid.css("border", "1px black solid");
    this.$grid.css("display", "inline-block");
    this.$grid.css("vertical-align", "top");  // Fixes shifting by one pixel bug
    this.$grid.width(gridWidth);
    this.$grid.height(gridHeight);

    // Helper function to make the tile with all the required css
    var makeTile = function(y, x) {

        var $tile = $("<div/>");

        //TODO use .css to set all values at once with an object
        $tile.css("position", "absolute");
        $tile.css("margin", "1px");

        //$tile.width(this.tileWidth-2);
        //$tile.height(this.tileHeight-2);
        $tile.css("width", this.tileWidth-2);
        $tile.css("height", this.tileHeight-2);

        // Set tile position
        $tile.css("top", y*this.tileHeight);
        $tile.css("left", x*this.tileWidth);

        // Set the "correct position" of the tile when checking if solved
        $tile.data("x", x);
        $tile.data("y", y);

        // Set the background image (clipped)
        $tile.css("background-image", "url("+level.image+")");
        $tile.css("background-size", gridWidth+"px "+gridHeight+"px");
        $tile.css("background-position", (-1*this.tileWidth*x-1)+"px "+(-1*this.tileHeight*y-1)+"px");

        // Setup trigger for clicking on tile
        var thisGrid = this;
        $tile.click(function() {
            if (!thisGrid.allowInput) return;
            thisGrid.allowInput = false;
            thisGrid.tryMoveTile_($(this), function(moved) { 
                if (moved && thisGrid.numIncorrect_() === 0) {
                    $img = $('<img style="height: 100%; width: 100%;" src="'+level.image+'"/>');
                    $img.fadeIn(COMPLETED_FADE_IN_DURATION, function() {
                        thisGrid.completionCallback();
                    });
                    thisGrid.$grid.prepend($img);
                } else {
                    thisGrid.allowInput = true; 
                }
            });
        });

        return $tile;
    }

    // Generate tiles
    this.tiles = [];
    for (var y=0; y<level.gridSize[1]; y++) {
        this.tiles[y] = [];
        for (var x=0; x<level.gridSize[0]; x++) {
            if (level.emptyTile[0] === x && level.emptyTile[1] === y) {
                this.tiles[y][x] = null;
            } else {
                var $tile = makeTile.call(this, y, x); //TODO do differently
                this.$grid.append($tile);
                this.tiles[y][x] = $tile;
            }
        }
    }

    // Add the grid to the container
    $container.append(this.$grid);
}

ShuffleGrid.prototype.start = function(completionCallback) {

    this.completionCallback = completionCallback;
    var thisGrid = this;
    var randomShuffle = function($lastTile) {

        // Keep shuffling until every tile has been moved away from it's original position
        if (thisGrid.numIncorrect_()>=thisGrid.tiles[0].length*thisGrid.tiles.length-1) {
            thisGrid.allowInput = true;
            return;
        }

        // Randomly select any tile from the grid and try to move it, try again if tile was not moved
        var $randomTile;
        do {
            $randomTile = thisGrid.tiles[Math.floor(Math.random()*thisGrid.tiles.length)][Math.floor(Math.random()*thisGrid.tiles[0].length)];
        } while ($lastTile !== null && $randomTile === $lastTile);

        thisGrid.tryMoveTile_($randomTile, function(moved) {
            randomShuffle(moved ? $randomTile : $lastTile);
        });
    };

    randomShuffle(null);
};

ShuffleGrid.prototype.destroy = function() {
    
};

ShuffleGrid.prototype.numIncorrect_ = function() {
    var count = 0;
    for (var y=0; y<this.tiles.length; y++) {
        for (var x=0; x<this.tiles[0].length; x++) {
            if (this.tiles[y][x] !== null && (this.tiles[y][x].data("x") !== x || this.tiles[y][x].data("y") !== y)) 
                count++;
        }
    }
    return count;
};

ShuffleGrid.prototype.tryMoveTile_ = function($tile, callback) {
    //TODO remove this
    if ($tile === null) {
        callback(false);
        return;
    }

    // Get x and y positions of this tile and the empty tile
    for (var y=0; y<this.tiles.length; y++) {
        for (var x=0; x<this.tiles[0].length; x++) {
            if (this.tiles[y][x]===null) {
                var emptyx = x, emptyy = y;
            } else if (this.tiles[y][x].data("x")===$tile.data("x") && 
                       this.tiles[y][x].data("y")===$tile.data("y")) {
                var thisx = x, thisy = y;
            }
        }
    }

    var animation = null;
    // Check if tile is in a movable position
    if (thisx===emptyx && thisy-emptyy===1) {  // Move this tile up
        animation = { top: "-="+this.tileHeight };
    } else if (thisx===emptyx && thisy-emptyy===-1) {  // Move this tile down
        animation = { top: "+="+this.tileHeight };
    } else if (thisx-emptyx===1 && thisy===emptyy) {  // Move this tile left
        animation = { left: "-="+this.tileWidth };
    } else if (thisx-emptyx===-1 && thisy===emptyy) {  // Move this tile right
        animation = { left: "+="+this.tileWidth };
    }

    // Move the tile, then swap tiles in the array and then call the callback function with the success value
    var tiles = this.tiles;
    if (animation !== null) {
        $tile.animate(animation, SLIDING_DURATION, function() {
            tiles[emptyy][emptyx] = tiles[thisy][thisx];
            tiles[thisy][thisx] = null;
            callback(true);
        });
    } else {
        callback(false);
    }
    
};


$(document).ready(function() {

    //loadNextLevel();
    var shuffleGrid = new ShuffleGrid(LEVELS[0], $("#container"), 400, 400);
    shuffleGrid.start(function() {console.log("Completed");});

    var shuffleGrid2 = new ShuffleGrid(LEVELS[1], $("#container"), 400, 400);
    shuffleGrid2.start(function() {console.log("Completed");});
    
});
