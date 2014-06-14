ShuffleGrid = require 'shufflegrid'
Solver = require 'solver/solver'

#TODO add a personality variable for storing these values
MOVE_INTERVAL = 500
NUM_ITERATIONS = 250

module.exports = class AIGrid extends ShuffleGrid
  
  readyForInput: ->
    setTimeout(@_makeMove, MOVE_INTERVAL)


  _makeMove: =>
    @solver.iterations(NUM_ITERATIONS)
    move = @solver.getMove()
    @tryMoveTile(move)


  setupInput: ->
    @solver = new Solver(this)
