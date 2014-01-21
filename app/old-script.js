var generateGrid = require('generategrid');

/* WordsearchGrid ************************************************************/

function WordsearchGrid($container, maxWidth, maxHeight) {
    var grid = generateGrid();
    var chars = grid.grid;

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

    $container.append($("<p>"+grid.words+"</p>"));
}

WordsearchGrid.prototype.start = function(completionCallback) {

}

/* ready *********************************************************************/

module.exports.startEverything = function() {
    var wordsearchGrid = new WordsearchGrid($("#container"), 400, 400);
    wordsearchGrid.start(null);
};
