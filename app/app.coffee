SharkGame = require('sharkgame')

startEverything = ->
  game = new SharkGame($('#container'))
  game.start()


module.exports = App =
  init: ->
    $(document).ready ->
      startEverything()
