# Number of available color classes defined in the Sass file
# Note that this must manually be kept up to date
NUM_COLORS = 5

# "Common" letters are more likely to occur than "uncommon" ones
ALPHABET = 'AABBCCDDEEFFGGHHIIJKLLMMNNOOPPQRSSTTUUVWXYZ'

# Directions words can be placed along, shuffled to avoid repeating patterns
DIRECTIONS = _.shuffle([ [1, 0], [0, 1], [-1, 0], [0, -1],
                         [1, 1], [1, -1], [-1, 1], [-1, -1] ])

# Helper function to join the letters from a path to form its word
wordFromPath = (path) ->
  word = ''
  if path?
    for cell in path
      word += cell.letter
  word


class Cell
  constructor: (@x, @y) ->
    @solvedColorClasses = []
    @isSelected = false
    @onPath = false
    @onCorrectPath = false

  willFitLetter: (letter) ->
    not @letter? or @letter is letter

  randomFill: ->
    @letter = _.sample(ALPHABET) unless @letter?


class LetterGrid
  constructor: (@width=8, @height=8, wordlist=defaultWordlist, attempts=10) ->
    # Make an empty grid
    @cells = (new Cell(x, y) for x in [0..@width-1] for y in [0..@height-1])
    @words = []

    # Try to fit in each word in the word list up to the max number of attempts
    for i in [1..attempts]
      for word in wordlist
        @_tryPutWord(word) unless word in @words

    # Fill in all unfilled slots with random letters
    for row in @cells
      for cell in row
        cell.randomFill()

    # Sort words by length (because it is generally easier for the player to 
    # find longer words first)
    @words = _.sortBy(@words, (word) -> -1*word.length)


  _tryPutWord: (word) ->
    # Choose a random start and end point
    [startX, startY] = [_.random(@width-1), _.random(@height-1)]
    [dirX, dirY] = DIRECTIONS[@words.length%DIRECTIONS.length]
    [endX, endY] = [startX+dirX*(word.length-1), startY+dirY*(word.length-1)]

    path = @_getPath([startX, startY], [endX, endY])
    #TODO move the path choosing code to a separate method

    # Return if word will not fit in grid
    return unless path?

    # Return if any cell is already filled with a conflicting letter
    for cell, i in path
      return unless cell.willFitLetter(word[i])

    # Set the new word
    for cell, i in path
      cell.letter = word[i]
    @words.push(word)


  _getPath: (start, end) ->
    #TODO can this be tidied up a bit?
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

  getPathFromCells: (start, end) ->
    @_getPath([start.x, start.y], [end.x, end.y])



angular.module('wordsearchApp', []).controller 'WordsearchCtrl', ($scope) ->

  $scope.grid = new LetterGrid()
  $scope.words = $scope.grid.words
  $scope.foundWords = []

  $scope.enableInput = true
  colorIndex = 1
  $scope.colorClass = 'color1'

  $scope.cellClicked = (cell) ->
    return unless $scope.enableInput
    if not $scope.selectedCell?
      cell.isSelected = true
      $scope.selectedCell = cell
    else
      path = $scope.grid.getPathFromCells($scope.selectedCell, cell)
      $scope.selectedCell.isSelected = false
      $scope.selectedCell = null
      $scope._submitPath(path)
      $scope.clearPath()


  $scope.updatePath = (cell) ->
    if $scope.selectedCell?
      path = $scope.grid.getPathFromCells($scope.selectedCell, cell)
      if path?
        for cell in path
          cell.onPath = true
          if wordFromPath(path) in $scope.words
            cell.onCorrectPath = true


  $scope.clearPath = ->
    for row in $scope.grid.cells
      for cell in row
        cell.onPath = false
        cell.onCorrectPath = false


  $scope._submitPath = (path) ->
    foundWord = wordFromPath(path)
    if foundWord in $scope.words
      $scope.words.splice($scope.words.indexOf(foundWord), 1)
      $scope.foundWords.unshift({ word: foundWord, colorClass: $scope.colorClass })
      for cell in path
        cell.solvedColorClasses.push($scope.colorClass)
      $scope.nextColor()

      if $scope.words.length is 0
        $scope.enableInput = false
        #TODO show a better congrats message
        alertCongrats = -> alert("Congratulations, you found all #{$scope.foundWords.length} words!")
        setTimeout(alertCongrats, 100)  # The delay allows the wordlist crossout to be updated


  $scope.nextColor = ->
    colorIndex = colorIndex%NUM_COLORS+1
    $scope.colorClass = "color#{colorIndex}"
