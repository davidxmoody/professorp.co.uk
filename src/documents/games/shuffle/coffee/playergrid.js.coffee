ShuffleGrid = require './shufflegrid'

module.exports = class PlayerGrid extends ShuffleGrid

  readyForInput: ->
    @allowInput = true


  setupInput: ->
    for tile in @tiles
      tile.$tile.on('click', $.proxy(@_tileClicked, this, tile))
    

  _tileClicked: (tile) ->
    return unless @allowInput
    @allowInput = false
    @tryMoveTile(tile)
