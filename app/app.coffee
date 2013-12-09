levels = require 'levels'
PlayerGrid = require 'playergrid'
AIGrid = require 'aigrid'
Random = require 'random'

startEverything = ->
  level = levels[1]
  maxShuffles = 50
  rand = new Random()
  startTime = (new Date()).getTime()

  playerGrid = new PlayerGrid(level, $('#player-container'), 420, 420)
  playerGrid.shuffle rand.clone(), maxShuffles, ->
    playerGrid.start ->
      timeTaken = Math.floor ((new Date()).getTime() - startTime)/1000
      console.log "Player finished in #{timeTaken} seconds, taking #{playerGrid.movesTaken} moves!"

  floppyGrid = new AIGrid(level, $('#ai-container'), 240, 240)
  floppyGrid.shuffle rand.clone(), maxShuffles, ->
    floppyGrid.start ->
      timeTaken = Math.floor ((new Date()).getTime() - startTime)/1000
      console.log "Floppy finished in #{timeTaken} seconds, taking #{floppyGrid.movesTaken} moves!"


module.exports = App =
  init: ->
    $(document).ready ->
      startEverything()
