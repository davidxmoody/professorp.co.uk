levels = require 'levels'
PlayerGrid = require 'playergrid'
AIGrid = require 'aigrid'
Random = require 'random'

startEverything = ->
  level = levels[1]
  rand = new Random()

  playerGrid = new PlayerGrid level, $('#player-container'), 420, 420
  playerGrid.shuffle rand.clone(), 6, ->
    playerGrid.start ->
      console.log 'player finished'

  floppyGrid = new AIGrid level, $('#ai-container'), 240, 240
  floppyGrid.shuffle rand.clone(), 6, ->
    floppyGrid.start ->
      console.log 'floppy finished'


module.exports = App =
  init: ->
    $(document).ready ->
      startEverything()
