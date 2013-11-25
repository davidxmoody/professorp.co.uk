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
      level: level
      maxWidth: maxWidth
      maxHeight: maxHeight

    @tiles = []

    thisGrid = this

    @$grid.children('.tile').each (index) ->
      $tile = $ this
      y = Math.floor index/level.gridSize[0]
      x = index%level.gridSize[0]
      $tile.data
        x: x
        y: y

      if thisGrid.tiles.length <= y then thisGrid.tiles[y] = []

      if $tile.hasClass('empty')
        thisGrid.tiles[y][x] = null
      else
        thisGrid.tiles[y][x] = $tile

        #TODO delegate this to the main grid
        $tile.click ->
          return unless thisGrid.allowInput
          thisGrid.allowInput = false
          thisGrid._tryMoveTile $(this), (moved) ->
            if moved and thisGrid._numIncorrect() is 0
              thisGrid._gridCompleted()
            else
              thisGrid.allowInput = true

    $container.append @$grid


  start: (@completionCallback) ->
    thisGrid = this
    resume = -> thisGrid.allowInput = true
    @_randomShuffle resume, null


  destroy: ->
    #TODO remove click event listeners?
    @$grid.remove()
    @tiles = null


  _randomShuffle: (callback, $lastTile) ->
    #TODO do this in a way that allows sequences of shuffles to be shared
    # Maybe a static method to generate a random sequence of u d l r chars
    # and then another method to convert that into moves
    if @_numIncorrect() >= @tiles[0].length*@tiles.length-1
      callback()
      return

    until $randomTile? and $randomTile isnt $lastTile
      $randomTile = @tiles[Math.floor(Math.random()*@tiles.length)][Math.floor(Math.random()*@tiles[0].length)]

    thisGrid = this
    @_tryMoveTile $randomTile, (moved) ->
      thisGrid._randomShuffle callback, if moved then $randomTile else $lastTile


module.exports = ShuffleGrid
