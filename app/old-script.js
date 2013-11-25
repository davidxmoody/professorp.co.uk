var LEVELS = require('levels');

ShuffleGrid = require("shufflegrid");
PlayerGrid = require("playergrid");
AIGrid = require("aigrid");


function startEverything() {

    var level = LEVELS[0];

    var playerFinished = false;
    var playerGrid = new PlayerGrid(level, $("#player-container"), 420, 420);
    playerGrid.start(function() {
        playerFinished = true;
        console.log("You completed your grid in "+playerGrid.movesTaken+" moves!");
    });

    var floppyGrid = new AIGrid(level, $("#ai-container"), 240, 240);
    floppyGrid.start(function() {
        console.log("Floppy completed his grid in "+floppyGrid.movesTaken+" moves!");
        if (playerFinished) {
            $("#floppy-thoughts").html("<em>You beat me, well done!</em>");
        } else {
            $("#floppy-thoughts").html("<em><strong>Yay!</strong> I won!</em>");
        }
    });

}

module.exports.startEverything = startEverything;
