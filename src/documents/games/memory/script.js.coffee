---
browserify: true
---

$ = require('jquery')
MemoryGrid = require('./memorygrid')

levels = [
  { numCards: 12, cardsPerRow: 4 }
  { numCards: 16, cardsPerRow: 4 }
  { numCards: 20, cardsPerRow: 5 }
  { numCards: 24, cardsPerRow: 6 }
  { numCards: 28, cardsPerRow: 7 }
]

nextLevel = ->
  return if levels.length is 0
  level = levels.shift()

  $container = $('#memory-game-container')
  $container.empty()
  new MemoryGrid($container, nextLevel, level.numCards, level.cardsPerRow)

  $('#level-progress > li').removeClass('active')
  $('#level-progress').append($("<li class='active'>#{level.numCards} cards</li>"))


$(document).ready ->
  nextLevel()
