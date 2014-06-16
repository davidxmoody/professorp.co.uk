ShuffleGrid = require './shufflegrid'
Solver = require './solver/solver'

#TODO add a personality variable for storing these values
MOVE_INTERVAL = 500
NUM_ITERATIONS = 250

module.exports = class AIGrid extends ShuffleGrid
  
  readyForInput: ->
    setTimeout(@_makeMove, MOVE_INTERVAL) if @gameStarted


  _makeMove: =>
    @solver.iterations(NUM_ITERATIONS)
    move = @solver.getMove()
    @tryMoveTile(move)


  setupInput: ->
    @solver = new Solver(this)


  makeFirstMove: ->
    # Hack to make the AIGrid wait for the player to begin before it starts
    @gameStarted = true
    @readyForInput()
