var LEVELS = [
  { words: ["SHARK",
            "AMMONITE",
            "CRINOID",
            "SHELL",
            "TRILOBITE",
            "BELEMNITE",
            "JURASSIC",
            "FOSSIL"],
    directionWeights: [10, 10, 2, 2, 4, 4, 1, 1],
    gridSize: [12, 12] }
];


/* WordsearchGrid ************************************************************/

function WordsearchGrid(level, $container, maxWidth, maxHeight) {
    var chars = this._generateCharacterArray(level);

    // Generate jQuery table to contain the characters
    var $table = $("<table/>");
    for (var y=0; y<chars.length; y++) {
        var $row = $("<tr/>");
        for (var x=0; x<chars[0].length; x++) {
            var $cell = $("<td>"+chars[y][x]+"</td>");
            $cell.css("font-size", "24px");
            //TODO add click function to cell
            $cell.appendTo($row);
        }
        $row.appendTo($table);
    }
    $table.appendTo($container);
}

WordsearchGrid.prototype.start = function(completionCallback) {

}

WordsearchGrid.prototype.destroy = function() {
    //TODO
}

WordsearchGrid.prototype._generateCharacterArray = function(level) {
    
    var REVERSE_CHANCE = 0.2;
    var AVAILABLE_CHARS = "x";
    //var AVAILABLE_CHARS = "abcdefghijklmnopqrstuvwxyz";
    var AVAILABLE_DIRECTIONS = [
      [1, 0],   // Right
      [0, 1],   // Down
      [-1, 0],  // Left
      [0, -1],  // Up
      [1, 1],   // Right and down
      [1, -1],  // Right and up
      [-1, 1],  // Left and down
      [-1, -1]  // Left and up
    ];

    //TODO increase frequency of common characters
    var randomChar = function() {
        return AVAILABLE_CHARS[Math.floor(Math.random()*AVAILABLE_CHARS.length)];
    };

    var randomDirection = function() {
        var weights = level.directionWeights;
        var totalWeight = 0.0;
        for (var i=0; i<weights.length; i++) totalWeight += weights[i];

        var randomSelector = Math.random()*totalWeight;
        for (var i=0; i<weights.length; i++) {
            if (randomSelector<=weights[i]) {
                return AVAILABLE_DIRECTIONS[i];
            } else {
                randomSelector -= weights[i];
            }
        }
        
        // If reached here then something failed
        console.log("random direction could not be chosen, using [1, 0]");
        return [1, 0];
    };

    // First initialise the grid with empty chars
    var chars = [];
    for (var y=0; y<level.gridSize[1]; y++) {
        chars[y] = [];
        for (var x=0; x<level.gridSize[0]; x++) {
            chars[y][x] = "";
        }
    }

    // Then try to put in all the required words
    var tryPutWord = function(word) {
        var direction = randomDirection();

        var minx = direction[0]<0 ? word.length-1 : 0;
        var maxx = direction[0]>0 ? level.gridSize[0]-word.length : level.gridSize[0]-1;
        var startx = minx + Math.floor(Math.random()*(maxx-minx));

        var miny = direction[1]<0 ? word.length-1 : 0;
        var maxy = direction[1]>0 ? level.gridSize[1]-word.length : level.gridSize[1]-1;
        var starty = miny + Math.floor(Math.random()*(maxy-miny));

        console.log([startx, starty], direction, word);

        // Check that the word will fit
        for (var x=startx, y=starty, i=0; i<word.length; i++) {
            if (chars[y][x] && chars[y][x] !== word[i]) return false;
            x += direction[0];
            y += direction[1];
        }

        // If it will then add it to the grid and return true
        for (var x=startx, y=starty, i=0; i<word.length; i++) {
            chars[y][x] = word[i];
            x += direction[0];
            y += direction[1];
        }
        return true;
    };

    for (var i=0; i<level.words.length; i++) {
        while (!tryPutWord(level.words[i])) {
            console.log("one failed attempt at placing word");
        }  //TODO add timeout/max tries
    }

    // Then fill in the rest of the unused spaces with random characters
    for (var y=0; y<level.gridSize[1]; y++) {
        for (var x=0; x<level.gridSize[0]; x++) {
            if (!chars[y][x]) {
                chars[y][x] = randomChar();
            }
        }
    }

    return chars;
}


/* ready *********************************************************************/

$(document).ready(function() {
    var wordsearchGrid = new WordsearchGrid(LEVELS[0], $("#container"), 400, 400);
    wordsearchGrid.start(null);
});
