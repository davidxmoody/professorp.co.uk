var LEVELS = [
  { name: "Ammonite", image: "images/ammonite.gif",
    gridSize: [3, 3], emptyTile: [2, 2] },
  { name: "Shark Teeth", image: "images/shark-teeth.gif",
    gridSize: [3, 4], emptyTile: [2, 3] },
  { name: "Ammonite Shell", image: "images/ammonite-shell.gif",
    gridSize: [4, 4], emptyTile: [3, 3] }
];


/* ShuffleGrid **************************************************************/

/* First create a grid from level data and maximum dimensions and tell it where to put itself
   Then shuffle the grid and start the game
   Give it a callback function to be called when the game is completed
   Finally destroy it once you are done with it and want to load another one */

function ShuffleGrid(level, $container, maxWidth, maxHeight) {

    // Setup timing "constants" for grid (can be changed if necessary)
    this.SLIDING_DURATION = 50;
    this.COMPLETED_FADE_IN_DURATION = 2000;

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
        //TODO remove this for non user interactive grids
        var thisGrid = this;
        $tile.click(function() {
            if (!thisGrid.allowInput) return;
            thisGrid.allowInput = false;
            thisGrid.tryMoveTile_($(this), function(moved) { 
                if (moved && thisGrid.numIncorrect_() === 0) {
                    $img = $('<img style="height: 100%; width: 100%;" src="'+level.image+'"/>');
                    $img.fadeIn(thisGrid.COMPLETED_FADE_IN_DURATION, function() {
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
    this.randomShuffle_(function() { thisGrid.allowInput = true; }, null);
};

ShuffleGrid.prototype.destroy = function() {
    this.$grid.remove();
    this.tiles = null;
};

ShuffleGrid.prototype.randomShuffle_ = function(callback, $lastTile) {
    // Keep shuffling until every tile has been moved away from it's original position
    if (this.numIncorrect_() >= this.tiles[0].length*this.tiles.length-1) {
        callback();
        return;
    }

    // Randomly select any tile from the grid and try to move it, select again if the tile was the last one which was moved
    var $randomTile;
    do {
        $randomTile = this.tiles[Math.floor(Math.random()*this.tiles.length)][Math.floor(Math.random()*this.tiles[0].length)];
    } while ($lastTile !== null && $randomTile === $lastTile);

    // Try to move the tile, call again upon completion with the last tile which was actually moved
    var thisGrid = this;
    this.tryMoveTile_($randomTile, function(moved) {
        thisGrid.randomShuffle_(callback, moved ? $randomTile : $lastTile);
    });
}

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
    var thisGrid = this;
    if (animation !== null) {
        $tile.animate(animation, thisGrid.SLIDING_DURATION, function() {
            thisGrid.tiles[emptyy][emptyx] = thisGrid.tiles[thisy][thisx];
            thisGrid.tiles[thisy][thisx] = null;
            callback(true);
        });
    } else {
        callback(false);
    }
    
};


/* AIShuffleGrid ************************************************************/

function GridState(pastPathCost, lastTile) {
    this.pastPathCost = pastPathCost;
    this.lastTile = lastTile;
    this.children = [];
}

GridState.prototype.init = function(shuffleGrid) {
    this.tiles = [];
    for (var y=0; y<shuffleGrid.tiles.length; y++) {
        this.tiles[y] = [];
        for (var x=0; x<shuffleGrid.tiles[0].length; x++) {
            if (shuffleGrid.tiles[y][x] == null) {
                this.tiles[y][x] = null;
            } else {
                this.tiles[y][x] = [shuffleGrid.tiles[y][x].data("y"), shuffleGrid.tiles[y][x].data("x")];
            }
        }
    }
}

GridState.prototype.generateChildren = function() {
    //TODO
}

GridState.prototype.pastPathCost = function() {

}

GridState.prototype.futurePathCost = function() {

}

GridState.prototype.totalPathCost = function() {

}

GridState.prototype.selectChild = function() {

}


function makeAIControlled(shuffleGrid) {

    var MOVE_INTERVAL = 1000;

    var chooseTile = function(shuffleGrid, $lastTile) {
        var $randomTile;
        do {
            $randomTile = shuffleGrid.tiles[Math.floor(Math.random()*shuffleGrid.tiles.length)][Math.floor(Math.random()*shuffleGrid.tiles[0].length)];
        } while ($lastTile !== null && $randomTile === $lastTile);
        return $randomTile;
    }

    var makeMove = function($lastTile) {
        var $tile = chooseTile(shuffleGrid, $lastTile);
        shuffleGrid.tryMoveTile_($tile, function(moved) {
            if (!moved) {
                makeMove($lastTile);
            } else {
                console.log("Moved tile");
                setTimeout(function() {makeMove($tile);}, MOVE_INTERVAL);
            }
        });
    }

    var startAI = function() {
        var initialGridState = new GridState(null, null);
        initialGridState.init(shuffleGrid);
        console.log(initialGridState.tiles);

        setTimeout(makeMove(null), MOVE_INTERVAL);
    }

    shuffleGrid.start = function(completionCallback) {
        shuffleGrid.completionCallback = completionCallback;
        shuffleGrid.randomShuffle_(startAI);
    };
}


/* ready ********************************************************************/

$(document).ready(function() {

    //loadNextLevel();
    var playerShuffleGrid = new ShuffleGrid(LEVELS[0], $("#player-container"), 420, 420);
    playerShuffleGrid.start(function() {console.log("Player completed");});

    var floppyShuffleGrid = new ShuffleGrid(LEVELS[0], $("#ai-container"), 240, 240);
    makeAIControlled(floppyShuffleGrid);
    floppyShuffleGrid.start(function() {console.log("AI completed");});
    $("#floppy-thoughts").html("<em>Lets begin!</em>");

});
