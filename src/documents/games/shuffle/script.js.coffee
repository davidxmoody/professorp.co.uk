---
browserify: true
referencesOthers: true
---

$ = require 'jquery'
levels = require './coffee/levels'
PlayerGrid = require './coffee/playergrid'
AIGrid = require './coffee/aigrid'
AIPersonality = require './coffee/aipersonality'
Random = require './coffee/random'

startGame = (levels) ->
  # Seed both grids with the same random number generator
  rand = new Random()

  playerGrid = new PlayerGrid(levels, rand.clone(), $('#player-container'))
  floppyGrid = new AIGrid(levels, rand.clone(), $('#ai-container'))

  # Create the personality and introduce himself
  floppyPersonality = new AIPersonality('Floppy')
  floppyPersonality.say("Hi, I'll start when you make your first move.")

  # Always stop floppy from making the first move in a sub-level the player has 
  # not reached yet until the player has made their first move in that
  # sub-level
  floppyGrid.on 'sublevel-complete', ->
    if floppyGrid.levelIndex>playerGrid.levelIndex
      floppyGrid.stopMoves()
      playerGrid.one 'sublevel-complete', ->
        playerGrid.one 'tile-moved', ->
          floppyGrid.makeFirstMove()

  # Make Floppy make his first move after the player makes theirs
  playerGrid.one 'tile-moved', ->
    floppyPersonality.randomSay("I should warn you that I'm really quite good at this game.", "Good luck, I think you're going to need it.")
    floppyGrid.makeFirstMove()

  # Floppy's comments for completing the first sublevel and then subsequent
  # sublevels (but not the final level)
  floppyGrid.one 'sublevel-complete', ->
    floppyPersonality.randomSay("The first level is always the easiest.", "That first level was a bit easy")
    floppyGrid.one 'shuffle-finished', ->
      floppyPersonality.randomSay("This should be a bit more challenging.", "Now the game really begins.")
    floppyGrid.on 'sublevel-complete', ->
      if playerGrid.levelIndex<floppyGrid.levelIndex
        floppyPersonality.randomSay("Looks like I'm winning so far.", "Don't feel bad for not playing as well as me, I am a super computer after all.")
      else
        floppyPersonality.randomSay("You're doing well!", "You're doing well so far, let's see if you can keep your lead.")

  # Floppy's comments for completing the final level
  playerComplete = false
  playerGrid.one 'level-complete', ->
    playerComplete = true
  floppyGrid.on 'level-complete', ->
    if playerComplete
      if playerGrid.movesTaken>floppyGrid.movesTaken
        floppyPersonality.randomSay("Well done, you did it quicker but I did it in #{playerGrid.movesTaken-floppyGrid.movesTaken} fewer moves.", "Congratulations, you beat me. You needed #{playerGrid.movesTaken} moves but I only needed #{floppyGrid.movesTaken} moves though.")
      else
        floppyPersonality.randomSay("Ah, well done you beat me.", "Oh no, I thought i was going to win that one.", "Well done, you did it in only #{playerGrid.movesTaken} moves which is pretty good for a human.")
    else
      floppyPersonality.randomSay("Yay! I win!", "I did it in only #{floppyGrid.movesTaken} moves, I think that's a new personal best.", "You did it in #{playerGrid.movesTaken} moves and I did it in #{floppyGrid.movesTaken} moves, not terrible for a human I suppose.")


$(document).ready ->
  # Hack to make the dropdown links load the correct level sets
  $('#coverLevels').click ->
    startGame(levels.coverLevels)
  $('#fossilLevels').click ->
    startGame(levels.fossilLevels)

  startGame(levels.coverLevels)
