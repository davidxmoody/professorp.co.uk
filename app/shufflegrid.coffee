gridTemplate = require 'views/grid'

module.exports = class ShuffleGrid
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

    $container.append @$grid


  destroy: ->
    @$grid.remove()
    @tiles = null


  _randomShuffle: (callback, $lastTile) ->
    #TODO do this in a way that allows sequences of shuffles to be shared
    # Maybe a static method to generate a random sequence of u d l r chars
    # and then another method to convert that into moves
    if @_numIncorrect() >= @tiles[0].length*@tiles.length-1
      callback?()
      return

    until $randomTile? and $randomTile isnt $lastTile
      $randomTile = @tiles[Math.floor(Math.random()*@tiles.length)][Math.floor(Math.random()*@tiles[0].length)]

    thisGrid = this
    @_tryMoveTile $randomTile, (moved) ->
      thisGrid._randomShuffle callback, if moved then $randomTile else $lastTile


  _numIncorrect: ->
    count = 0
    for y in [0..@tiles.length-1]
      for x in [0..@tiles[0].length-1]
        #TODO add isCorrectlyPlaced method?
        count++ unless @tiles[y][x] is null or @tiles[y][x].data('x') is x and @tiles[y][x].data('y') is y
    count


  _tryMoveTile: ($tile, callback) ->

    for y in [0..@tiles.length-1]
      for x in [0..@tiles[0].length-1]
        if @tiles[y][x] is null
          emptyx = x
          emptyy = y
        else
          if @tiles[y][x].data('x') is $tile.data('x') and @tiles[y][x].data('y') is $tile.data('y')
            thisx = x
            thisy = y

    if thisx is emptyx and thisy is emptyy+1
      animation = top: '-='+@tileHeight
    else if thisx is emptyx and thisy is emptyy-1
      animation = top: '+='+@tileHeight
    else if thisx is emptyx+1 and thisy is emptyy
      animation = left: '-='+@tileWidth
    else if thisx is emptyx-1 and thisy is emptyy
      animation = left: '+='+@tileWidth

    thisGrid = this
    if animation?
      $tile.animate animation, @SLIDING_DURATION, ->
        thisGrid.tiles[emptyy][emptyx] = thisGrid.tiles[thisy][thisx]
        thisGrid.tiles[thisy][thisx] = null
        thisGrid.movesTaken++
        callback true
    else
      callback false

  
  _gridCompleted: ->
    $img = $ "<img style='height: 100%; width: 100%;' src='#{@level.image}'/>"
    thisGrid = this
    $img.fadeIn @COMPLETED_FADE_IN_DURATION, ->
      thisGrid.completionCallback()
    @$grid.prepend $img
