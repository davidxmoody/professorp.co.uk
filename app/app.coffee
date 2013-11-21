old_script = require 'old-script'
grid = require 'views/grid'

testLevel = { name: "Ammonite", image: "images/ammonite.gif", gridSize: [3, 3], emptyTile: [2, 2] }

module.exports = App =
  init: ->
    $(document).ready ->
      #old_script.startEverything()
      newGrid = grid
        maxWidth: 402
        maxHeight: 402
        level: testLevel
      $('#player-container').html(newGrid)
