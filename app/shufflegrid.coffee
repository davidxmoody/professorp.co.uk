Tile = require 'tile'
Random = require 'random'

module.exports = class ShuffleGrid
  constructor: (@levels, @random, @$container, @maxWidth, @maxHeight) ->
    @random ?= new Random()
    @levelIndex = 0
    

  init: (@completeCallback) ->
    @loadLevel(@levels[@levelIndex])
    @shuffle()


  loadLevel: (@level) ->
    #TODO check that all previous level data gets overwritten/erased

    @lastShuffledTile = null
    #TODO set min and max shuffles from level data
    @numShuffles = 50
    @movesTaken = 0 #TODO track moves for each sublevel?

    #TODO add option to keep aspect ratio
    # Calculate dimensions
    tileWidth = Math.floor(@maxWidth/level.gridSize[0])
    tileHeight = Math.floor(@maxHeight/level.gridSize[1])

    gridWidth = tileWidth*level.gridSize[0]
    gridHeight = tileHeight*level.gridSize[1]

    # Make the jQuery grid
    @$grid = $ '<div/>'
    @$grid.css
      position: 'relative'
      border: '1px black solid'
      display: 'inline-block'
      'vertical-align': 'top'  #TODO is this needed any more?
      width: gridWidth
      height: gridHeight

    # Make the tiles
    @tiles = []
    for y in [0..level.gridSize[1]-1]
      for x in [0..level.gridSize[0]-1]
        tile = new Tile(x, y, tileWidth, tileHeight, level)
        @tiles.push(tile)
        @$grid.append(tile.$tile)
        @emptyTile = tile if tile.empty

    @$container.empty()
    @$container.append(@$grid)


  shuffle: =>
    #TODO fix below comment and add min moves?
    # Stop if maxMoves reached or grid is completely mixed up
    if @numShuffles<=0 or @_isMixed()
      @setupInput()
      @readyForInput()
      return

    # Choose a random movable tile but don't move the last tile to be moved
    # (to prevent an annoying double-move behaviour)
    availableMoves = @_movableTiles(false)
    tileToMove = @random.choose(availableMoves)

    # Move chosen tile and schedule the next move
    @numShuffles--
    @lastShuffledTile = tileToMove
    tileToMove.swapWith(@emptyTile, @shuffle)
    

  _numIncorrect: ->
    (tile for tile in @tiles when not tile.correctlyPlaced()).length


  _isMixed: ->
    @_numIncorrect()==@tiles.length


  _isSolved: ->
    @_numIncorrect()==0


  _movableTiles: (allowLastShuffled) ->
    tile for tile in @tiles when tile.adjacentTo(@emptyTile) and \
         (allowLastShuffled or tile isnt @lastShuffledTile)


  tryMoveTile: (tile) ->
    if tile.adjacentTo(@emptyTile)
      @movesTaken++
      tile.swapWith @emptyTile, =>
        if @_isSolved()
          @levelComplete()
        else
          @readyForInput()
    else
      @readyForInput()


  levelComplete: ->
    $img = $ "<img style='height: 100%; width: 100%;' src='#{@level.image}'/>"
    thisGrid = this
    $img.fadeIn 1000, ->
      thisGrid.levelIndex++
      if thisGrid.levelIndex>=thisGrid.levels.length
        thisGrid.completeCallback()
      else
        thisGrid.loadLevel(thisGrid.levels[thisGrid.levelIndex])
        thisGrid.shuffle()
    @$grid.prepend $img


  readyForInput: ->
    # "Abstract" method meant to be overridden by subclasses
    # Gets called whenever the grid enters the "waiting for move" state
    console.log('"readyForInput()" called on a ShuffleGrid instance')


  setupInput: ->
    # "Abstract" method meant to be overridden by subclasses
    # Gets called once for each level, just after the grid is shuffled
    console.log('"setupInput()" called on a ShuffleGrid instance')
