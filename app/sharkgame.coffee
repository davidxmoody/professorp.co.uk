SharkGameTemplate = require('sharkgametemplate')

module.exports = class SharkGame
  constructor: (@$container) ->
    @$game = SharkGameTemplate()
    @$container.append(@$game)
