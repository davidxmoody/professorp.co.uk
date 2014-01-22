defaultWordlist = require './wordlist'


# Some helper methods

# Choose a random element from an array (or string)
choose = (array) -> array[Math.floor(Math.random()*array.length)]

randomStartingPoint = (width, height) ->
  [choose([0..width-1]), choose([0..height-1])]

randomDirection = ->
  choose([ [1, 0], [0, 1], [-1, 0], [0, -1],
           [1, 1], [1, -1], [-1, 1], [-1, -1] ])

randomChar = ->
  # "Common" letters are more likely to occur than "uncommon" ones
  choose('AABBCCDDEEFFGGHHIIJKLLMMNNOOPPQRSSTTUUVWXYZ')


module.exports = class LetterGrid
  constructor: (@width=8, @height=8, wordlist=defaultWordlist) ->
    @grid = (null for x in [1..@width] for y in [1..@height])
    @words = []
    @_fillGrid(wordlist, 20)


  _tryPutWord: (word) ->
    [startX, startY] = randomStartingPoint(@width, @height)
    [diffX, diffY] = randomDirection()

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


  _fillGrid: (wordlist, attempts) ->
    # Try to fit in each word in the word list up to the max number of attempts
    for i in [1..attempts]
      for word in wordlist
        @_tryPutWord(word) if word not in @words

    # Fill in all unfilled slots with random letters
    for x in [0..@width-1]
      for y in [0..@height-1]
        if @grid[y][x] is null
          @grid[y][x] = randomChar()


  reconstructWord: (start, end) ->
    [x, y] = start
    [endX, endY] = end

    diffX = endX - x
    diffY = endY - y

    stepX = if diffX==0 then 0 else diffX/Math.abs(diffX)
    stepY = if diffY==0 then 0 else diffY/Math.abs(diffY)

    # Check that a straight line can be drawn between start and end
    if diffX is 0 and diffY is 0 or
        (diffX isnt 0 and diffY isnt 0) and Math.abs(diffX) isnt Math.abs(diffY)
      return null

    word = ''
    until x is endX and y is endY
      word += @grid[y][x]
      x += stepX
      y += stepY
    word += @grid[y][x]

    word
