SharkGame = require('sharkgame')

startEverything = ->
  game = new SharkGame($('#container'))


module.exports = App =
  init: ->
    $(document).ready ->
      startEverything()
