$ = require 'jquery'
Tile = require './tile'
Random = require './random'

module.exports = class ShuffleGrid
  constructor: (@levels, @random, @$container) ->
    @random ?= new Random()
    @movesTaken = 0
    @levelIndex = 0
    
    # Make the jQuery grid
    @$grid = $('<div class="shuffle-grid"></div>')
    @$container.append(@$grid)

    # Setup custom event handling (delegated to the jQuery @$grid)
    @trigger = $.proxy(@$grid.trigger, @$grid)
    @on = $.proxy(@$grid.on, @$grid)
    @one = $.proxy(@$grid.one, @$grid)
    @off = $.proxy(@$grid.off, @$grid)

    # Load first level and shuffle
    @loadLevel(@levels[@levelIndex])
    @shuffle()


  _getNextLevel: ->
    @levels[++@levelIndex]


  loadLevel: (@level) ->
    # Do no more than this number of shuffles, chosen by trial and error
    @numShuffles = 50

    @tiles = @_makeTiles(level)
    @emptyTile = tile for tile in @tiles when tile.empty

    for tile in @tiles
      @$grid.append(tile.$tile)


  _makeTiles: (level) ->
    tileWidth = Math.floor(@$grid.width()/level.gridSize[0])
    tileHeight = Math.floor(@$grid.height()/level.gridSize[1])

    tiles = []
    for y in [0..level.gridSize[1]-1]
      for x in [0..level.gridSize[0]-1]
        tile = new Tile(x, y, tileWidth, tileHeight, level)
        tiles.push(tile)
    tiles


  shuffle: =>
    # Stop if the shuffle limit is reached or if the grid is mixed up
    if @numShuffles<=0 or @_isMixed()
      @setupInput()
      @readyForInput()
      @trigger('shuffle-finished')

    else
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
      @trigger('tile-moved')
      @movesTaken++
      tile.swapWith @emptyTile, =>
        if @_isSolved()
          @levelComplete()
        else
          @readyForInput()
    else
      @readyForInput()


  levelComplete: ->
    oldTiles = @tiles
    nextLevel = @_getNextLevel()
    if nextLevel
      @trigger('sublevel-complete')
      subtilePosition = @level.subtilePosition
      @level = nextLevel
      @tiles = @_makeTiles(@level)
      @emptyTile = tile for tile in @tiles when tile.empty

      for tile, i in @tiles
        return if tile.empty
        oldCSS = tile.$tile.css(['width', 'height', 'left', 'top'])
        
        tile.$tile.css
          width: tile.level.gridSize[0]*tile.width-2
          height: tile.level.gridSize[1]*tile.height-2
          left: (tile.origX-subtilePosition[0])*(tile.width+2)*tile.level.gridSize[0]
          top: (tile.origY-subtilePosition[1])*(tile.height+2)*tile.level.gridSize[1]

        tile.$tile.fadeIn 2000, ->
          for oldTile in oldTiles
            oldTile.$tile.remove()

        tile.$tile.animate oldCSS, 4000, (if i is 0 then @shuffle else null)
        @$grid.append(tile.$tile)
    
    else
      @trigger('level-complete')
      $img = $ "<img style='height: 100%; width: 100%;' src='#{@level.image}'/>"
      thisGrid = this
      $img.fadeIn 1000, ->
        nextLevel = thisGrid._getNextLevel()
        if nextLevel?
          thisGrid.loadLevel(nextLevel)
          thisGrid.shuffle()
        else
          thisGrid.completeCallback()
      @$grid.prepend $img


  readyForInput: ->
    # "Abstract" method meant to be overridden by subclasses
    # Gets called whenever the grid enters the "waiting for move" state
    console.log('"readyForInput()" called on a ShuffleGrid instance')


  setupInput: ->
    # "Abstract" method meant to be overridden by subclasses
    # Gets called once for each level, just after the grid is shuffled
    console.log('"setupInput()" called on a ShuffleGrid instance')
