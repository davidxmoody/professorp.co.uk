Node = require './node'

module.exports = class Solver
  constructor: (@grid) ->
    @root = new Node(grid)


  iterate: ->
    # Select leaf node in tree
    node = @root
    while node.hasChildren()
      node = node.selectChild()

    # Has a solution been found?
    return true if node.isSolved()

    # Generate children
    node.generateChildren()

    # Update f-costs throughout the tree
    while node?
      node.updateCosts()
      node = node.getParent()

    # Solution not found in this iteration
    return false
      

  iterations: (maxIterations) ->
    numIterations = 0
    while numIterations<maxIterations
      break if @iterate()
      numIterations++
    return numIterations

  getMove: ->
    return null if @root.isSolved()
    return null unless @root.hasChildren()

    # Choose new root and chop off unreachable branches
    @root = @root.selectChild()
    @root.parent = null
    @root.lastTile
