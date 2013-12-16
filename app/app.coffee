levels = require 'levels'
PlayerGrid = require 'playergrid'
AIGrid = require 'aigrid'
Random = require 'random'

startEverything = ->
  rand = new Random()
  startTime = (new Date()).getTime()

  playerGrid = new PlayerGrid(levels, rand.clone(), $('#player-container'), 420, 420)
  playerGrid.init ->
    timeTaken = Math.floor ((new Date()).getTime() - startTime)/1000
    console.log "Player finished in #{timeTaken} seconds, taking #{playerGrid.movesTaken} moves!"
    

  floppyGrid = new AIGrid(levels, rand.clone(), $('#ai-container'), 240, 240)
  floppyGrid.init ->
    timeTaken = Math.floor ((new Date()).getTime() - startTime)/1000
    console.log "Floppy finished in #{timeTaken} seconds, taking #{floppyGrid.movesTaken} moves!"


module.exports = App =
  init: ->
    $(document).ready ->
      startEverything()
