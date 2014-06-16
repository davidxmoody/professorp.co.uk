---
browserify: true
referencesOthers: true
---

levels = require './coffee/levels'
PlayerGrid = require './coffee/playergrid'
AIGrid = require './coffee/aigrid'
AIPersonality = require './coffee/aipersonality'
Random = require './coffee/random'

$(document).ready ->
  rand = new Random()

  floppyPersonality = new AIPersonality('Floppy')
  floppyPersonality.say("Hi, I'll start when you make your first move.")

  playerGrid = new PlayerGrid(levels, rand.clone(), $('#player-container'))
  playerGrid.init ->
    console.log "Player finished in #{playerGrid.movesTaken} moves!"
    
  floppyGrid = new AIGrid(levels, rand.clone(), $('#ai-container'))
  floppyGrid.init ->
    console.log "Floppy finished in #{floppyGrid.movesTaken} moves!"

  # Delay Floppy start until player has moved one tile
  playerGrid.one 'tile-moved', ->
    floppyPersonality.say("I should warn you that I'm really quite good at this game.")
    floppyGrid.makeFirstMove()

  # Floppy's comments for completing the first sublevel and then subsequent
  # sublevels (but not the final level)
  floppyGrid.one 'sublevel-complete', ->
    floppyPersonality.randomSay("The first level is always the easiest.")
    floppyGrid.one 'shuffle-finished', ->
      floppyPersonality.say("This should be a bit more challenging.")
    floppyGrid.on 'sublevel-complete', ->
      if playerGrid.nextLevelIndex<floppyGrid.nextLevelIndex
        floppyPersonality.randomSay("Looks like I'm winning so far.")
      else
        floppyPersonality.randomSay("You're doing well!")

  # Floppy's comments for completing the final level
  playerComplete = false
  playerGrid.one 'level-complete', ->
    playerComplete = true
  floppyGrid.on 'level-complete', ->
    if playerComplete
      floppyPersonality.randomSay("Ah, well done you beat me.", "Oh no, I thought i was going to win that one.")
    else
      floppyPersonality.randomSay("Yay! I win!")