ShuffleGrid = require 'shufflegrid'
Solver = require 'solver/solver'

module.exports = class AIGrid extends ShuffleGrid

  start: (@completionCallback) ->
    MOVE_INTERVAL = 1000
    NUM_ITERATIONS = 250
    
    solver = new Solver(this)

    makeMove = =>
      solver.iterations(NUM_ITERATIONS)
      move = solver.getMove()
      @tryMoveTile move, (moved) =>
        if moved and @_numIncorrect() is 0
          @_gridCompleted()
        else
          setTimeout makeMove, MOVE_INTERVAL

    setTimeout makeMove, MOVE_INTERVAL
