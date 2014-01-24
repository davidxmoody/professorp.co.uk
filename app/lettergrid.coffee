defaultWordlist = require './wordlist'

#TODO move this
solvedNumber = 0


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
  constructor: ($container, @width=8, @height=8, wordlist=defaultWordlist) ->
    # Create empty grid then fill with words
    @grid = (null for x in [1..@width] for y in [1..@height])
    @_fillGrid(wordlist, 20)

    @selected = null

    @$grid = $('<div/>')
    @$grid.addClass('ws-grid')
    for y in [0..@height-1]
      $row = $('<div/>')
      $row.appendTo(@$grid)
      for x in [0..@width-1]
        $cell = $('<div/>')
        $cell.addClass('ws-cell')
        $cell.text(@grid[y][x])
        $cell.data('position', [x, y])
        $cell.addClass("row#{y}")
        $cell.addClass("col#{x}")
        $cell.appendTo($row)
        $cell.click($.proxy(@_cellClicked, this, $cell, x, y))
    @$grid.appendTo($container)

    console.log(@words)


  _cellClicked: ($cell, x, y) ->
    if @selected?
      path = @reconstructWord(@selected.data('position'), $cell.data('position'))
      foundWord = ''
      if path?
        for letter in path
          foundWord += letter.letter

      if foundWord in @words
        console.log("\"#{foundWord}\" has been found")
        @words.splice(@words.indexOf(foundWord), 1)
        if @words.length is 0
          console.log("Congratulations, you won!")
          $('.ws-cell').off('click')
        else
          console.log(@words)

        for letter in path
          $(".row#{letter.y}.col#{letter.x}").addClass("solved#{solvedNumber}")
        solvedNumber = (solvedNumber+1)%3

      else
        console.log("\"#{foundWord}\" is not a correct word")

      @selected.removeClass('selected')
      @selected = null
    else
      @selected = $cell
      $cell.addClass('selected')


  _fillGrid: (wordlist, attempts) ->
    @words = []
    # Try to fit in each word in the word list up to the max number of attempts
    for i in [1..attempts]
      for word in wordlist
        @_tryPutWord(word) if word not in @words

    # Fill in all unfilled slots with random letters
    for x in [0..@width-1]
      for y in [0..@height-1]
        if @grid[y][x] is null
          @grid[y][x] = randomChar()


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

    letterList = []

    for i in [1..100]
      letterList.push {
        letter: @grid[y][x]
        x: x
        y: y
      }
      if x is endX and y is endY
        return letterList
      x += stepX
      y += stepY

    return null
