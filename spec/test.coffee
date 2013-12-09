Solver = require '../app/solver/solver'
FakeGrid = require './fakegrid'
Random = require '../app/random'


makeGrid = (seed=0.23456)->
  grid = new FakeGrid(4, 4)
  rand = new Random(seed)
  grid.shuffle(20000, rand)
  grid

seeds = (Math.random() for i in [1..10])

makeGrids = ->
  makeGrid(seed) for seed in seeds


solveGrid = (grid, iterations) ->
  solver = new Solver(grid)
  moves = ''
  maxChildren = 0
  iterationsTally = 0

  for i in [1..10000]
    numIter = solver.iterations(iterations)
    iterationsTally += numIter
    if not solutionFound? and numIter==0
      solutionFound = i

    maxChildren = Math.max(solver.root.numChildren, maxChildren)

    move = solver.getMove()
    if move?
      grid.tryMoveTile(move)
      moves += "#{move.origX}#{move.origY} "

    if grid.isSolved()
      return {
        steps: i
        solutionFound: solutionFound
        iterations: iterations
        totalIterations: iterationsTally
        maxChildren: maxChildren
        moves: moves
      }

numIterations = 1
while numIterations<10000
  stepsTotal = 0
  stepsCount = 0

  for grid in makeGrids()
    result = solveGrid(grid, numIterations)
    stepsTotal += if result? then result.steps else 1000
    stepsCount++

  avgSteps = stepsTotal/stepsCount
  console.log("#{numIterations},#{avgSteps}")

  numIterations = Math.floor(numIterations*1.2)+2
