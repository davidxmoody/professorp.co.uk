var LEVELS = [
  { images: ["images/Image0.jpg",
             "images/Image1.jpg",
             "images/Image2.jpg",
             "images/Image3.jpg",
             "images/Image4.jpg",
             //"images/Image5.jpg",
             //"images/Image6.jpg",
             //"images/Image7.jpg",
             "images/Image8.jpg"],
    back: "images/back.gif"}
];


/* MemoryGame ****************************************************************/

function MemoryGrid(level, $container, maxWidth, maxHeight) {
    
    // Setup timing "constants" for grid (can be changed if necessary)
    this.TILE_FLIP_DURATION = 50;

    // Keep track of how many moves were taken
    this.movesTaken = 0;

    // Make a note of the level for later use
    this.level = level;

    // Disable user input until level has been started
    this.allowInput = false;

    // No tiles are selected initially
    this.$selectedTile1 = null;
    this.$selectedTile2 = null;

    // Create the grid and set properties
    this.$grid = $("<div/>");
    this.$grid.css("position", "relative");
    this.$grid.css("border", "1px black solid");
    this.$grid.css("display", "inline-block");
    //this.$grid.css("vertical-align", "top");  // Fixes shifting by one pixel bug
    this.$grid.width(maxWidth);
    this.$grid.height(maxHeight);

    // Generate tiles
    this.tiles = [];
    for (var i=0; i<level.images.length*2; i++) {

        var $tile = $("<div/>");
        
        //$tile.css("position", "absolute");
        $tile.css("margin-top", "20px");
        $tile.css("margin-left", "20px");
        $tile.css("display", "inline-block");
        
        $tile.css("border-radius", "2px");

        $tile.css("width", 100);  //TODO change this
        $tile.css("height", 100);

        //$tile.css("top", 10);
        //$tile.css("left", i*101);

        $tile.data("front", "url("+level.images[Math.floor(i/2)]+")");
        $tile.data("back", "url("+level.back+")");

        $tile.data("state", "hidden");

        // Set the background image
        $tile.css("background-image", $tile.data("back"));
        $tile.css("background-size", "100% 100%");

        // Setup trigger for clicking on tile
        var thisGrid = this;
        $tile.click(function() {
            if (!thisGrid.allowInput) return;
            thisGrid.toggleTile_($(this));
        });

        this.$grid.append($tile);
        this.tiles[i] = $tile;

    }

    // Shuffle tiles around a bit
    //TODO put this into a separate method
    for (var i=0; i<100; i++) {
        var $randomTile1 = this.tiles[Math.floor(Math.random()*this.tiles.length)];
        var $randomTile2 = this.tiles[Math.floor(Math.random()*this.tiles.length)];
        $randomTile1.after($randomTile2);
    }

    // Add the grid to the container
    $container.append(this.$grid);
}

MemoryGrid.prototype.start = function(completionCallback) {
    this.completionCallback = completionCallback;
    this.allowInput = true;
};

MemoryGrid.prototype.destroy = function() {
    //TODO
};

MemoryGrid.prototype.toggleTile_ = function($tile) {

    // Only toggle tile if it is already hidden
    if ($tile.data("state") !== "hidden") return;

    // If two (incorrectly matched) tiles were previously selected then cover them up
    if (this.$selectedTile1 !== null && this.$selectedTile2 !== null) {
        this.hideTile_(this.$selectedTile1);
        this.$selectedTile1 = null;

        this.hideTile_(this.$selectedTile2);
        this.$selectedTile2 = null;
    }

    // If no tiles were previously selected then show just the first
    if (this.$selectedTile1 === null && this.$selectedTile2 === null) {
        this.showTile_($tile);
        this.$selectedTile1 = $tile;

    // If one tile was previously selected then show the new one and check for a match
    } else {
        this.showTile_($tile);
        this.$selectedTile2 = $tile;

        if (this.$selectedTile1.data("front") === this.$selectedTile2.data("front")) {
            this.$selectedTile1.data("state", "solved");
            this.$selectedTile2.data("state", "solved");

            this.$selectedTile1 = null;
            this.$selectedTile2 = null;
        }
    }

    this.movesTaken++;
    console.log(this.numIncorrect_());
}

MemoryGrid.prototype.hideTile_ = function($tile) {
    $tile.css("background-image", $tile.data("back"));
    $tile.data("state", "hidden");
}

MemoryGrid.prototype.showTile_ = function($tile) {
    $tile.css("background-image", $tile.data("front"));
    $tile.data("state", "shown");
}

MemoryGrid.prototype.numIncorrect_ = function() {
    var count = 0;
    for (var i=0; i<this.tiles.length; i++) {
        if (this.tiles[i].data("state") === "solved") {
            count++;
        }
    }
    return count;
}


/* ready *********************************************************************/

$(document).ready(function() {
    var memoryGrid = new MemoryGrid(LEVELS[0], $("#container"), 500, 390);
    memoryGrid.start(null);
});
