Solver = require '../app/solver/solver'
FakeGrid = require './fakegrid'


describe 'A Solver', ->
  grids = []
  for y in [2..5]
    for x in [2..5]
      grid = new FakeGrid(x, y)
      grid.shuffle(Math.floor(Math.random()*1000))
      grids.push(grid)

  it 'solves easy grids within 100,000 iterations', ->
    for grid in grids
      continue if grid.tiles.length>10  # Too hard
      solver = new Solver(grid)
      expect(solver.iterations(100000)).toBe(true)

  it 'solves hard grids with in multiple stages', ->
    for grid in grids
      solver = new Solver(grid)
      for i in [1..1000]
        solver.iterations(1000)
        expect(grid.tryMoveTile(solver.getMove()))
        break if grid.isSolved()

      expect(grid.isSolved()).toBe(true)
