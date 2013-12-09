Node = require '../app/solver/node'
FakeGrid = require './fakegrid'


describe 'A Node', ->
  nodes = null

  beforeEach ->
    grids = []
    for y in [2..5]
      for x in [2..5]
        grids.push(new FakeGrid(x, y))

    nodes = []
    for grid in grids
      for i in [0..10]
        grid.shuffle(i*13-2)
        nodes.push(new Node(grid))


  it 'builds itself from an unshuffled shuffle grid', ->
    grid = new FakeGrid(3, 3)
    node = new Node(grid)

    expect(node.g).toBe(0)
    expect(node.state).toBeDefined()
    expect(node.state.length).toBe(3)
    expect(node.state[0].length).toBe(3)

    expect(node.state[0][0].origX).toBe(0)
    expect(node.state[0][0].origY).toBe(0)
    expect(node.state[0][0].empty).toBe(false)
    
    expect(node.state[1][2].origX).toBe(2)
    expect(node.state[1][2].origY).toBe(1)
    expect(node.state[1][2].empty).toBe(false)
    
    expect(node.state[2][2].origX).toBe(2)
    expect(node.state[2][2].origY).toBe(2)
    expect(node.state[2][2].empty).toBe(true)

    expect(node.state.length).toBe(3)
    expect(node.state[0].length).toBe(3)

  it 'builds itself from a shuffled shuffle grid', ->
    grid = new FakeGrid(3, 3)
    grid.shuffle(1)
    node = new Node(grid)

    cornerTileId = [node.state[2][2].origX, node.state[2][2].origY]
    expect(cornerTileId).not.toEqual([2, 2])

  it 'starts with no children', ->
    for node in nodes
      expect(node.children).not.toBeDefined()
      expect(node.hasChildren()).toBe(false)

  it 'generates its own children', ->
    for node in nodes
      node.generateChildren()
      expect(node.children).toBeDefined()
      expect(node.hasChildren()).toBe(true)

  it 'has the correct number of children', ->
    for node in nodes
      node.generateChildren()
      expect(node.children.length).toBeGreaterThan(0)
      expect(node.children.length).toBeLessThan(5)

  it 'selects its minimum child', ->
    for node in nodes
      node.generateChildren()
      selectedChild = node.selectChild()
      expect(node.children).toContain(selectedChild)
      for child in node.children
        if child isnt selectedChild
          expect(child.f).not.toBeLessThan(selectedChild.f)
