gridTemplate = require 'views/grid'

class ShuffleGrid
  constructor: (@level, $container, maxWidth, maxHeight) ->
    @SLIDING_DURATION = 50
    @COMPLETED_FADE_IN_DURATION = 2000

    @movesTaken = 0
    @allowInput = false

    # Calculate dimensions
    #TODO add option to keep aspect ratio
    @tileWidth = Math.floor(maxWidth/level.gridSize[0])
    @tileHeight = Math.floor(maxHeight/level.gridSize[1])

    @$grid = $ gridTemplate
      'level': level
      'maxWidth': maxWidth
      'maxHeight': maxHeight

    @tiles = []

    thisGrid = this

    @$grid.children('.tile').each (index) ->
      $tile = $ this
      y = Math.floor index/level.gridSize[0]
      x = index%level.gridSize[0]
      $tile.data
        'x': x
        'y': y

      if thisGrid.tiles.length <= y then thisGrid.tiles[y] = []

      if $tile.hasClass('empty')
        thisGrid.tiles[y][x] = null
      else
        thisGrid.tiles[y][x] = $tile

        $tile.click ->
          return unless thisGrid.allowInput
          thisGrid.allowInput = false
          thisGrid._tryMoveTile $(this), (moved) ->
            if moved and thisGrid._numIncorrect() is 0
              thisGrid._gridCompleted()
            else
              thisGrid.allowInput = true

    $container.append @$grid

module.exports = ShuffleGrid
