ShuffleGrid = require 'shufflegrid'

module.exports = class PlayerGrid extends ShuffleGrid
  constructor: (level, $container, maxWidth, maxHeight) ->
    super(level, $container, maxWidth, maxHeight)

    @allowInput = false

    for tile in @tiles
      tile.$tile.on 'click', $.proxy(@_tileClicked, this, tile)


  _tileClicked: (tile) ->
    return unless @allowInput
    @allowInput = false
    @tryMoveTile tile, (moved) =>
      if moved and @_numIncorrect() is 0
        @_gridCompleted()
      else
        @allowInput = true


  start: (@completionCallback) ->
    @allowInput = true
