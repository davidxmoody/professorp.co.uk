LetterGrid = require 'lettergrid'

solvedNumber = 0
selected = null

startEverything = ->
  grid = new LetterGrid()

  $grid = $('<div/>')
  $grid.addClass('ws-grid')
  for y in [0..grid.height-1]
    $row = $('<div/>')
    $row.appendTo($grid)
    for x in [0..grid.width-1]
      $cell = $('<div/>')
      $cell.addClass('ws-cell')
      $cell.text(grid.grid[y][x])
      $cell.data('position', [x, y])
      $cell.addClass("row#{y}")
      $cell.addClass("col#{x}")
      $cell.appendTo($row)

  $grid.appendTo($('#container'))
  $('.ws-cell').click ->
    if selected?
      path = grid.reconstructWord(selected.data('position'), $(this).data('position'))
      foundWord = ''
      if path?
        for letter in path
          foundWord += letter.letter

      if foundWord in grid.words
        console.log("\"#{foundWord}\" has been found")
        grid.words.splice(grid.words.indexOf(foundWord), 1)
        if grid.words.length is 0
          console.log("Congratulations, you won!")
          $('.ws-cell').off('click')
        else
          console.log(grid.words)

        for letter in path
          $(".row#{letter.y}.col#{letter.x}").addClass("solved#{solvedNumber}")
        solvedNumber = (solvedNumber+1)%3

      else
        console.log("\"#{foundWord}\" is not a correct word")

      selected.removeClass('selected')
      selected = null
    else
      selected = $(this)
      $(this).addClass('selected')
  console.log grid.words

  


module.exports = App =
  init: ->
    $(document).ready ->
      startEverything()
