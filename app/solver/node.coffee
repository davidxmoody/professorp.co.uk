module.exports = class Node
  constructor: (shuffleGrid) ->
    # Initialise from the given shuffleGrid if possible
    if shuffleGrid?
      [cols, rows] = shuffleGrid.level.gridSize
      tiles = shuffleGrid.tiles

      @state = for y in [0..rows-1]
        for x in [0..cols-1]
          matchedTile = tile for tile in tiles when x is tile.x and y is tile.y
          matchedTile

      @g = 0
      @h = @futurePathCost()
      @f = @g + @h
      @numChildren = 0


  hasChildren: ->
    @children?


  selectChild: ->
    # Return the child with the smallest f-value
    @children.reduce (a, b) ->
      if a.f<b.f then a else b
      

  isSolved: ->
    @h? and @h is 0


  generateChildren: ->
    @children = []
    
    # Find empty tile
    for row, y in @state
      for tile, x in row
        if tile.empty
          emptyX = x
          emptyY = y


    movableTiles = []

    if emptyX >= 1 then movableTiles.push @state[emptyY][emptyX-1]
    if emptyX < @state[0].length-1 then movableTiles.push @state[emptyY][emptyX+1]
    
    if emptyY >= 1 then movableTiles.push @state[emptyY-1][emptyX]
    if emptyY < @state.length-1 then movableTiles.push @state[emptyY+1][emptyX]

    for tileToMove in movableTiles
      # Ignore tile if it was the last one to be moved (because a double-move
      # will make the child's state identical to the parent's which is pointless)
      continue if tileToMove is @lastTile

      # Generate a new node from the tile to move and current state
      child = new Node()
      child.state = []
      for row, y in @state
        child.state[y] = []
        for tile, x in row
          if tile is tileToMove
            child.state[y][x] = @state[emptyY][emptyX]
          else if tile.empty
            child.state[y][x] = tileToMove
          else
            child.state[y][x] = @state[y][x]

      child.parent = this
      child.lastTile = tileToMove
      child.g = @g+1
      child.h = child.futurePathCost()
      child.f = child.g + child.h
      child.numChildren = 0

      @children.push child
      

  updateCosts: ->
    @f = @selectChild().f
    @numChildren = 0
    @numChildren += child.numChildren+1 for child in @children


  getParent: ->
    @parent


  getLastTile: ->
    @lastTile


  futurePathCost: ->
    # Sum the distances of each (non-empty) tile from its correct position
    # Will always be admissible because each move can only move a tile by 
    # a distance of one place
    total = 0
    for row, y in @state
      for tile, x in row
        unless tile.empty
          total += Math.abs(y-tile.origY) + Math.abs(x-tile.origX)
    total
