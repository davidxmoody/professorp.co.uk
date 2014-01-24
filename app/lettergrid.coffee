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


class Cell
  constructor: (@x, @y) ->

  willFitLetter: (letter) ->
    not @letter? or @letter is letter

  setLetter: (@letter) ->

  randomFill: ->
    @letter = randomChar() unless @letter?


module.exports = class LetterGrid
  constructor: ($container, @width=8, @height=8, wordlist=defaultWordlist) ->
    # Create empty grid then fill with words
    @cells = (new Cell(x, y) for x in [0..@width-1] for y in [0..@height-1])
    @_fillGrid(wordlist, 15)

    @selected = null

    @$grid = $('<div/>')
    @$grid.addClass('ws-grid')
    for y in [0..@height-1]
      $row = $('<div/>')
      $row.appendTo(@$grid)
      for x in [0..@width-1]
        $cell = $('<div/>')
        $cell.addClass('ws-cell')
        $cell.text(@cells[y][x].letter)
        @cells[y][x].$cell = $cell
        $cell.appendTo($row)
        $cell.click($.proxy(@_cellClicked, this, @cells[y][x]))
    @$grid.appendTo($container)

    console.log(@words)


  _cellClicked: (clicked) ->
    if @selected?
      path = @path([@selected.x, @selected.y], [clicked.x, clicked.y])
      foundWord = ''
      if path?
        for cell in path
          foundWord += cell.letter

      if foundWord in @words
        console.log("\"#{foundWord}\" has been found")
        @words.splice(@words.indexOf(foundWord), 1)
        if @words.length is 0
          console.log("Congratulations, you won!")
          $('.ws-cell').off('click')
        else
          console.log(@words)

        # Highlight cells in path
        for cell in path
          cell.$cell.addClass("solved#{solvedNumber}")
        solvedNumber = (solvedNumber+1)%3

      else
        console.log("\"#{foundWord}\" is not a correct word")

      @selected.$cell.removeClass('selected')
      @selected = null
    else
      @selected = clicked
      clicked.$cell.addClass('selected')


  _fillGrid: (wordlist, attempts) ->
    @words = []
    # Try to fit in each word in the word list up to the max number of attempts
    for i in [1..attempts]
      for word in wordlist
        @_tryPutWord(word) if word not in @words

    # Fill in all unfilled slots with random letters
    cell.randomFill() for cell in row for row in @cells


  _tryPutWord: (word) ->
    # Choose a random start and end point
    [startX, startY] = randomStartingPoint(@width, @height)
    [dirX, dirY] = randomDirection()
    [endX, endY] = [startX+dirX*(word.length-1), startY+dirY*(word.length-1)]

    cells = @path([startX, startY], [endX, endY])

    # Return if word will not fit in grid
    return false unless cells?

    # Return if any cell is already filled
    for cell, i in cells
      return false unless cell.willFitLetter(word[i])

    # Set the new word
    for cell, i in cells
      cell.setLetter(word[i])
    @words.push(word)
    return true


  path: (start, end) ->
    [x, y] = start
    [endX, endY] = end

    diffX = endX - x
    diffY = endY - y

    stepX = if diffX==0 then 0 else diffX/Math.abs(diffX)
    stepY = if diffY==0 then 0 else diffY/Math.abs(diffY)

    cellList = []

    while x>=0 and y>=0 and x<@width and y<@height
      cellList.push(@cells[y][x])
      if x is endX and y is endY
        return cellList
      x += stepX
      y += stepY

    return null
