Tile = require 'tile'
Random = require 'random'

COMPLETED_FADE_IN_DURATION = 2000

module.exports = class ShuffleGrid
  constructor: (@level, $container, maxWidth, maxHeight) ->
    
    @lastMovedTile = null
    @movesTaken = 0 #TODO make this work

    #TODO add option to keep aspect ratio
    # Calculate dimensions
    tileWidth = Math.floor(maxWidth/level.gridSize[0])
    tileHeight = Math.floor(maxHeight/level.gridSize[1])

    gridWidth = tileWidth*level.gridSize[0]
    gridHeight = tileHeight*level.gridSize[1]

    # Make the jQuery grid
    @$grid = $ '<div/>'
    @$grid.css
      position: 'relative'
      border: '1px black solid'
      display: 'inline-block'
      'vertical-align': 'top'
      width: gridWidth
      height: gridHeight

    # Make the tiles
    @tiles = []
    for y in [0..level.gridSize[1]-1]
      for x in [0..level.gridSize[0]-1]
        tile = new Tile x, y, tileWidth, tileHeight, level
        @tiles.push tile
        @$grid.append tile.$tile
        @emptyTile = tile if tile.empty

    $container.append @$grid


  destroy: ->
    @$grid.remove()
    @tiles = null


  shuffle: (random, maxMoves, callback) ->
    # Stop if maxMoves reached or grid is completely mixed up
    if maxMoves<=0 or @_isMixed()
      callback()
      return

    # Initialise random if necessary
    random ?= new Random()

    # Choose a random movable tile, don't move the last tile to be moved
    # (to prevent an annoying double-move behaviour)
    availableMoves = @_movableTiles(false)
    tileToMove = random.choose(availableMoves)

    # Move chosen tile and schedule the next move
    @tryMoveTile tileToMove, =>
      @shuffle random, maxMoves-1, callback
    

  _numIncorrect: ->
    (tile for tile in @tiles when not tile.correctlyPlaced()).length


  _isMixed: ->
    @_numIncorrect()==@tiles.length


  _movableTiles: (allowLastMoved) ->
    #TODO make this more readable
    tile for tile in @tiles when tile.vectorTo(@emptyTile).abs()==1 and tile isnt @lastMovedTile


  tryMoveTile: (tile, callback) ->
    # Move the given tile if it is a legal move (i.e. empty tile is adjacent)
    vector = tile.vectorTo(@emptyTile)
    if vector.abs() == 1
      @lastMovedTile = tile
      tile.swapWith(@emptyTile, callback)
    else
      callback?(false)

  
  _gridCompleted: ->
    $img = $ "<img style='height: 100%; width: 100%;' src='#{@level.image}'/>"
    thisGrid = this
    $img.fadeIn COMPLETED_FADE_IN_DURATION, ->
      thisGrid.completionCallback()
    @$grid.prepend $img


  getState: ->
    #TODO
