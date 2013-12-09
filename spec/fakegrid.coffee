class FakeTile
  constructor: (@x, @y, @empty) ->
    @origX = x
    @origY = y


module.exports = class FakeGrid
  constructor: (cols, rows) ->
    @level = gridSize: [cols, rows]
    @tiles = []
    for y in [0..rows-1]
      for x in [0..cols-1]
        empty = x is cols-1 and y is rows-1
        @tiles.push(new FakeTile(x, y, empty))
    @emptyTile = tile for tile in @tiles when tile.empty

  shuffle: (numMoves, rand) ->
    while numMoves > 0
      if rand?
        randTile = rand.choose(@tiles)
      else
        randTile = @tiles[Math.floor(@tiles.length*Math.random())]
      numMoves-- if @tryMoveTile(randTile)

  tryMoveTile: (tile) ->
    if tile.x is @emptyTile.x and Math.abs(tile.y-@emptyTile.y)==1 or \
       tile.y is @emptyTile.y and Math.abs(tile.x-@emptyTile.x)==1
      # Swap tiles
      oldx = @emptyTile.x
      oldy = @emptyTile.y
      @emptyTile.x = tile.x
      @emptyTile.y = tile.y
      tile.x = oldx
      tile.y = oldy
      true
    else
      false

  isSolved: ->
    for tile in @tiles
      return false if tile.x isnt tile.origX or tile.y isnt tile.origY
    return true
