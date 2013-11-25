var LEVELS = require('levels');


/* ShuffleGrid **************************************************************/

/* First create a grid from level data and maximum dimensions and tell it where to put itself
   Then shuffle the grid and start the game
   Give it a callback function to be called when the game is completed
   Finally destroy it once you are done with it and want to load another one */

function ShuffleGrid(level, $container, maxWidth, maxHeight) {

    this.SLIDING_DURATION = 50;
    this.COMPLETED_FADE_IN_DURATION = 2000;

    this.movesTaken = 0;
    this.level = level;
    this.allowInput = false;

    // Tile heights and widths include everything (border, padding, width)
    this.tileWidth = Math.floor(maxWidth/level.gridSize[0]);
    this.tileHeight = Math.floor(maxWidth/level.gridSize[1]);


    var template = require("views/grid");

    this.$grid = $(template({ "level": level, "maxWidth": maxWidth, "maxHeight": maxHeight }));

    var $tiles = this.$grid.children(".tile");

    this.tiles = [];

    var thisGrid = this;
    $tiles.each(function(index) {
        var $tile = $(this);
        var y = Math.floor(index/level.gridSize[0]);
        var x = index%level.gridSize[0];
        $tile.data({ "x": x, "y": y });

        if (thisGrid.tiles.length <= y) thisGrid.tiles[y] = [];
        if ($tile.hasClass('empty')) {
            thisGrid.tiles[y][x] = null;
        } else {
            thisGrid.tiles[y][x] = $tile;

            
            $tile.click(function() {
                if (!thisGrid.allowInput) return;
                thisGrid.allowInput = false;
                thisGrid._tryMoveTile($(this), function(moved) { 
                    if (moved && thisGrid._numIncorrect() === 0) {
                        thisGrid._gridCompleted();
                    } else {
                        thisGrid.allowInput = true; 
                    }
                });
            });
        }
    });

    $container.append(this.$grid);
}

ShuffleGrid.prototype.start = function(completionCallback) {

    this.completionCallback = completionCallback;
    var thisGrid = this;
    this._randomShuffle(function() { thisGrid.allowInput = true; }, null);
};

ShuffleGrid.prototype.destroy = function() {
    this.$grid.remove();
    this.tiles = null;
};

ShuffleGrid.prototype._randomShuffle = function(callback, $lastTile) {
    // Stop shuffling once every tile has been moved away from it's original position
    if (this._numIncorrect() >= this.tiles[0].length*this.tiles.length-1) {
        callback();
        return;
    }

    // Randomly select a tile from the grid and try to move it, repeat if that tile had just been moved
    var $randomTile;
    do {
        $randomTile = this.tiles[Math.floor(Math.random()*this.tiles.length)][Math.floor(Math.random()*this.tiles[0].length)];
    } while ($lastTile !== null && $randomTile === $lastTile);

    // Try to move the selected tile, recursively call self upon completion, passing the last tile which was actually moved
    var thisGrid = this;
    this._tryMoveTile($randomTile, function(moved) {
        thisGrid._randomShuffle(callback, moved ? $randomTile : $lastTile);
    });
};

ShuffleGrid.prototype._numIncorrect = function() {
    var count = 0;
    for (var y=0; y<this.tiles.length; y++) {
        for (var x=0; x<this.tiles[0].length; x++) {
            if (this.tiles[y][x] !== null && (this.tiles[y][x].data("x") !== x || this.tiles[y][x].data("y") !== y)) 
                count++;
        }
    }
    return count;
};

ShuffleGrid.prototype._tryMoveTile = function($tile, callback) {
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
            thisGrid.movesTaken++;
            callback(true);
        });
    } else {
        callback(false);
    }
    
};

ShuffleGrid.prototype._gridCompleted = function() {
    var $img = $('<img style="height: 100%; width: 100%;" src="'+this.level.image+'"/>');
    var thisGrid = this;
    $img.fadeIn(this.COMPLETED_FADE_IN_DURATION, function() {
        thisGrid.completionCallback();
    });
    this.$grid.prepend($img);
};


/* AIShuffleGrid ************************************************************/

// Nodes contain expected cost and current state
// Expected cost is calculated from the past path cost plus heuristic future cost
// Future cost is estimated by taking the sum of the distances of each tile from their correct positions

// First generate the initial node from the initial grid state
// Go down the tree repeatedly selecting the children with the lowest expected cost
// Once you reach a node with no children then generate it's children and add them to the tree
// Calculate expected values for the children and propagate the minimum of those up the tree, updating the 
// expected values of all of the nodes above it to be equal to the minimum of their respective children
// Once a node is reached which has a future cost of 0 then a solution has been found, calculate solution from tree


function generateRoot(shuffleGrid) {
    var root = {};
    root.state = [];
    for (var y=0; y<shuffleGrid.tiles.length; y++) {
        root.state[y] = [];
        for (var x=0; x<shuffleGrid.tiles[0].length; x++) {
            if (shuffleGrid.tiles[y][x] == null) {
                root.state[y][x] = null;
            } else {
                root.state[y][x] = [shuffleGrid.tiles[y][x].data("y"), shuffleGrid.tiles[y][x].data("x")];
            }
        }
    }

    root.parent = null;
    root.lastTile = null;
    root.g = 0;
    root.h = futurePathCost(root);
    root.f = root.h;

    return root;
}

// Sum the distances of each tile from its correct position
function futurePathCost(node) {
    var total = 0;
    for (var y=0; y<node.state.length; y++) {
        for (var x=0; x<node.state[0].length; x++) {
            var tile = node.state[y][x];
            if (tile == null) continue;
            total += Math.abs(y-tile[0]) + Math.abs(x-tile[1]);
        }
    }
    return total;
}

function selectRecursively(node) {
    // Assume that the children are already sorted in ascending order
    while (typeof node.children !== "undefined") {
        node = node.children[0];
    }
    return node;
}

function generateChildren(node) {
    node.children = [];
    // First find null tile
    for (var y=0; y<node.state.length; y++) {
        for (var x=0; x<node.state[0].length; x++) {
            var tile = node.state[y][x];
            if (tile == null) {
                var nully = y;
                var nullx = x;
            }
        }
    }

    // Try selecting the tiles adjacent to the null tile
    var tiles = [];

    if (nullx >= 1) tiles.push(node.state[nully][nullx-1]);  // Left of null tile
    if (nullx < node.state[0].length-1) tiles.push(node.state[nully][nullx+1]);  // Right of null tile

    if (nully >= 1) tiles.push(node.state[nully-1][nullx]);  // Above null tile
    if (nully < node.state.length-1) tiles.push(node.state[nully+1][nullx]);  // Below null tile

    // For each movable tile, generate a new child with that tile moved into the null tile position
    // Skip over the tile if it was the last tile to be moved (duplicate moves can never be useful)
    for (var i=0; i<tiles.length; i++) {
        var tileToMove = tiles[i];
        if (node.lastTile === tileToMove) continue;
        
        // Generate new node and set its state
        var newNode = {};
        newNode.state = [];
        for (var y=0; y<node.state.length; y++) {
            newNode.state[y] = [];
            for (var x=0; x<node.state[0].length; x++) {
                var oldTile = node.state[y][x];
                if (oldTile === tileToMove) {
                    newNode.state[y][x] = null;
                } else if (nully === y && nullx === x) {
                    newNode.state[y][x] = tileToMove;
                } else {
                    newNode.state[y][x] = oldTile;
                }
            }
        }

        // Create all other values for the node
        newNode.parent = node;
        newNode.lastTile = tileToMove;
        newNode.g = node.g + 1;
        newNode.h = futurePathCost(newNode);
        newNode.f = newNode.g + newNode.h;

        node.children.push(newNode);

    }

    // Update the f values for all of the nodes parents in the tree
    updateRecursively(node);
    
}

function updateRecursively(node) {
    while (node.parent !== null) {
        // Sort children in ascending order by f value (most promising first)
        node.children.sort(function(a, b) {return a.f-b.f});
        
        // Update f value of current node to be the minimum of its children
        node.f = node.children[0].f;

        // Keep going up until the top of the tree has been reached
        node = node.parent;
    }
}

function iterate(rootNode) {
    var selectedNode = selectRecursively(rootNode);
    if (selectedNode.h === 0) return true;
    generateChildren(selectedNode);
    updateRecursively(selectedNode);
    return false;
}

function iterations(rootNode, number) {
    for (var i=0; i<number; i++) {
        if (iterate(rootNode)) {
            return true;
        }
    }
    return false;
}


function makeAIControlled(shuffleGrid) {

    var MOVE_INTERVAL = 1000;
    var NUM_ITERATIONS = 30;

    var makeMove = function(root) {
        // First perform some iterations
        var solutionFound = iterations(root, NUM_ITERATIONS);
        if (solutionFound) {
            $("#floppy-thoughts").html("<em>I think I've got it!</em>");
        }

        // Set the new root to the most promising child, chop off unreachable branches
        root = root.children[0];
        root.parent = null;

        // Find out which shuffle grid tile corresponds to the node tile
        var lastTile = root.lastTile;
        for (var y=0; y<shuffleGrid.tiles.length; y++) {
            for (var x=0; x<shuffleGrid.tiles[0].length; x++) {
                var $gridTile = shuffleGrid.tiles[y][x];
                if ($gridTile !== null && lastTile[0] == $gridTile.data("y") && lastTile[1] == $gridTile.data("x")) {
                    var $tileToMove = $gridTile;
                }
            }
        }

        shuffleGrid._tryMoveTile($tileToMove, function(moved) {
            if (!moved) {
                console.log("Tile was not moved: " + lastTile);
            } else {
                if (shuffleGrid._numIncorrect() === 0) {
                    // AI has successfully completed the grid!
                    shuffleGrid._gridCompleted();
                } else {
                    // Still moves to go, schedule next move
                    setTimeout(function() {makeMove(root);}, MOVE_INTERVAL);
                }
            }
        });
    }

    var startAI = function() {
        $("#floppy-thoughts").html("<em>Lets begin!</em>");

        var root = generateRoot(shuffleGrid);
        setTimeout(makeMove(root), MOVE_INTERVAL);
    }

    shuffleGrid.start = function(completionCallback) {
        shuffleGrid.completionCallback = completionCallback;
        shuffleGrid._randomShuffle(startAI);
    };
}


/* ready ********************************************************************/

function startEverything() {

    var level = LEVELS[1];

    var playerFinished = false;
    var playerShuffleGrid = new ShuffleGrid(level, $("#player-container"), 420, 420);
    playerShuffleGrid.start(function() {
        playerFinished = true;
        console.log("You completed your grid in "+playerShuffleGrid.movesTaken+" moves!");
    });

    var floppyShuffleGrid = new ShuffleGrid(level, $("#ai-container"), 240, 240);
    makeAIControlled(floppyShuffleGrid);
    floppyShuffleGrid.start(function() {
        console.log("Floppy completed his grid in "+floppyShuffleGrid.movesTaken+" moves!");
        if (playerFinished) {
            $("#floppy-thoughts").html("<em>You beat me, well done!</em>");
        } else {
            $("#floppy-thoughts").html("<em><strong>Yay!</strong> I won!</em>");
        }
    });

}

module.exports.startEverything = startEverything;
