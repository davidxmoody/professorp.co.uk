wordlist = require './wordlist'

class LetterGrid
  constructor: (@width, @height) ->
    @grid = (null for x in [1..@width] for y in [1..@height])
    @words = []

  randomStartingPoint: ->
    [Math.floor(Math.random()*@width), Math.floor(Math.random()*@height)]

  randomDirection: ->
    [ [1, 0], [0, 1], [-1, 0], [0, -1],
      [1, 1], [1, -1], [-1, 1], [-1, -1]
    ][Math.floor(Math.random()*8)]

  tryPutWord: (word) ->
    [startX, startY] = @randomStartingPoint()
    [diffX, diffY] = @randomDirection()

    # Check that the word will fit at the chosen position
    x = startX
    y = startY
    for i in [0..word.length-1]
      # Word has gone off the grid
      if x<0 or x>=@grid[0].length or y<0 or y>=@grid.length
        return false

      # Letter slot is already occupied and doesn't fit with the current word
      if @grid[y][x]? and @grid[y][x] isnt word[i]
        return false

      # Move to next letter position
      x += diffX
      y += diffY

    # Place the word into the grid
    x = startX
    y = startY
    for i in [0..word.length-1]
      @grid[y][x] = word[i]
      x += diffX
      y += diffY

    @words.push(word)
    return true


module.exports = (width=8, height=8, words=wordlist) ->
  grid = new LetterGrid(width, height)
  for i in [1..20]
    for word in words
      grid.tryPutWord(word) if word not in grid.words

  fillerLetters = 'AABBCCDDEEFFGGHHIIJKLLMMNNOOPPQRSSTTUUVWXYZ'
  randomChar = -> fillerLetters[Math.floor(Math.random()*fillerLetters.length)]

  for x in [0..grid.width-1]
    for y in [0..grid.height-1]
      if grid.grid[y][x] is null
        grid.grid[y][x] = randomChar()
  grid
