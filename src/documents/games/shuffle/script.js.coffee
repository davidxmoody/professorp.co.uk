---
browserify: true
---

levels = require './coffee/levels'
PlayerGrid = require './coffee/playergrid'
AIGrid = require './coffee/aigrid'
Random = require './coffee/random'

startEverything = ->
  rand = new Random()
  startTime = (new Date()).getTime()

  playerGrid = new PlayerGrid(levels, rand.clone(), $('#player-container'))
  playerGrid.init ->
    timeTaken = Math.floor ((new Date()).getTime() - startTime)/1000
    console.log "Player finished in #{timeTaken} seconds, taking #{playerGrid.movesTaken} moves!"
    

  floppyGrid = new AIGrid(levels, rand.clone(), $('#ai-container'))
  floppyGrid.init ->
    timeTaken = Math.floor ((new Date()).getTime() - startTime)/1000
    console.log "Floppy finished in #{timeTaken} seconds, taking #{floppyGrid.movesTaken} moves!"


$(document).ready ->
  startEverything()
