ShuffleGrid = require 'shufflegrid'
Solver = require 'solver'

module.exports = class AIGrid extends ShuffleGrid
  constructor: (level, $container, maxWidth, maxHeight) ->
    super(level, $container, maxWidth, maxHeight)


  start: (@completionCallback) ->
    @_randomShuffle @_startAI


  #TODO does this need to be a fat arrow?
  _startAI: =>
    MOVE_INTERVAL = 1000
    
    #TODO supply the Solver with the current state instead of the whole grid
    solver = new Solver this

    moveSingleTile = =>
      # Note that the move is actually the jquery tile to move
      move = solver.getMove()
      @_tryMoveTile move, (moved) =>
        if @_numIncorrect() is 0
          @_gridCompleted()
        else
          setTimeout moveSingleTile, MOVE_INTERVAL

    setTimeout moveSingleTile, MOVE_INTERVAL
