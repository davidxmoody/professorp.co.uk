levels = require 'levels'
PlayerGrid = require 'playergrid'
AIGrid = require 'aigrid'

startEverything = ->
  level = levels[0]

  playerGrid = new PlayerGrid level, $('#player-container'), 420, 420
  playerGrid.start ->
    console.log "You completed your grid in #{playerGrid.movesTaken} moves!"

  floppyGrid = new AIGrid level, $('#ai-container'), 240, 240
  floppyGrid.start ->
    console.log "Floppy completed his grid in #{floppyGrid.movesTaken} moves!"


module.exports = App =
  init: ->
    $(document).ready ->
      startEverything()
