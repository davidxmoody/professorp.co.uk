defaultWordlist = require './wordlist'

# This should be equal to the number of colors defined in the .scss file
#TODO update to reflect the .scss file
NUM_COLORS = 5

# Some helper methods

# Choose a random element from an array (or string)
choose = (array) -> array[Math.floor(Math.random()*array.length)]

randomStartingPoint = (width, height) ->
  [choose([0..width-1]), choose([0..height-1])]

#TODO make it so that directions that have already been chosen are less likely to appear again
randomDirection = ->
  choose([ [1, 0], [0, 1], [-1, 0], [0, -1],
           [1, 1], [1, -1], [-1, 1], [-1, -1] ])

randomChar = ->
  # "Common" letters are more likely to occur than "uncommon" ones
  choose('AABBCCDDEEFFGGHHIIJKLLMMNNOOPPQRSSTTUUVWXYZ')

wordFromPath = (path) ->
  word = ''
  if path?
    for cell in path
      word += cell.letter
  word


class Cell
  constructor: (@x, @y) ->

  willFitLetter: (letter) ->
    not @letter? or @letter is letter

  setLetter: (@letter) ->

  randomFill: ->
    @letter = randomChar() unless @letter?


module.exports = class LetterGrid
  #TODO separate the initial grid generation into a separate superclass
  constructor: ($container, @width=8, @height=8, wordlist=defaultWordlist) ->
    # Create empty grid then fill with words
    @cells = (new Cell(x, y) for x in [0..@width-1] for y in [0..@height-1])
    @_fillGrid(wordlist, 15)

    @$wordlist = $('#wordlist')
    for word in @words
      $("<div class='word-wrapper'><div class='word'>#{word}</div></div>").appendTo(@$wordlist)

    @selected = null
    @hovered = null

    @$grid = $('<div/>')
    @$grid.addClass('ws-grid')
    @colorIndex = 1
    @$grid.addClass("color#{@colorIndex}")
    for row, y in @cells
      $row = $('<div/>')
      $row.appendTo(@$grid)
      for cell, x in row
        cell.$cell = $("<div class='ws-cell'>#{cell.letter}</div>")
        cell.$cell.appendTo($row)
        cell.$cell.click($.proxy(@_cellClicked, this, cell))
        cell.$cell.mouseenter($.proxy(@_cellMouseenter, this, cell))
        cell.$cell.mouseleave($.proxy(@_cellMouseleave, this, cell))
    @$grid.appendTo($container)

    # Start game by displaying word list
    console.log(@words)
    #TODO add words to #wordlist instead


  _cellClicked: (clicked) =>
    if @selected?
      path = @path([@selected.x, @selected.y], [clicked.x, clicked.y])
      foundWord = wordFromPath(path)

      if foundWord in @words
        console.log("\"#{foundWord}\" has been found")
        @words.splice(@words.indexOf(foundWord), 1)
        $('#wordlist .word-wrapper').each ->
          if $(this).text() is foundWord
            $(this).addClass('strikethrough')
            #TODO fix strikethrough colors
            $(this).addClass("strikethrough1")
            $(this).appendTo($('#wordlist'))
        if @words.length is 0
          console.log("Congratulations, you won!")
          $('.ws-cell').off('click')
        else
          console.log(@words)

        # Highlight cells in path
        for cell in path
          cell.$cell.removeClass('path')
          cell.$cell.removeClass('correct-path')
          @_cellSolved(cell)

        @_nextColor()

      else
        if foundWord and foundWord.length>1
          console.log("\"#{foundWord}\" is not a correct word")
          for cell in path
            cell.$cell.removeClass('path')
            cell.$cell.removeClass('correct-path')

      @selected.$cell.removeClass('selected')
      @selected.$cell.removeClass('path')
      @selected = null

    else
      @selected = clicked

    @_updateColors()


  _cellMouseenter: (currentCell) ->
    @hovered = currentCell
    @_updateColors()


  _cellMouseleave: (currentCell) ->
    @hovered = null
    @_updateColors()


  _cellSolved: (cell) ->
    cell.$cell.append("<div class='solved color#{@colorIndex}'></div>")


  _updateColors: ->
    if @selected?
      # If there is a selected cell then make it appear selected
      @selected.$cell.addClass('selected')

      # If there is a hovered cell as well then highlight the path between them
      if @hovered?
        @selectedPath = @path([@selected.x, @selected.y], [@hovered.x, @hovered.y])
        correctPath = wordFromPath(@selectedPath) in @words
        if @selectedPath?
          for cell in @selectedPath
            cell.$cell.addClass(if correctPath then 'correct-path' else 'path')

      # If there was a previously selected path but isnt now un-highlight it
      else
        if @selectedPath?
          for cell in @selectedPath
            cell.$cell.removeClass('path')
            cell.$cell.removeClass('correct-path')
        @selectedPath = null


  _nextColor: ->
    @$grid.removeClass("color#{@colorIndex}")
    @colorIndex = @colorIndex%NUM_COLORS+1
    @$grid.addClass("color#{@colorIndex}")


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
