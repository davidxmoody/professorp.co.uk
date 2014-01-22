LetterGrid = require 'lettergrid'

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
      $cell.appendTo($row)

  $grid.appendTo($('#container'))
  $('.ws-cell').click ->
    if selected?
      foundWord = grid.reconstructWord(selected.data('position'), $(this).data('position'))
      if foundWord in grid.words
        console.log("\"#{foundWord}\" has been found")
        grid.words.splice(grid.words.indexOf(foundWord), 1)
        if grid.words.length is 0
          console.log("Congratulations, you won!")
          $('.ws-cell').off('click')
        else
          console.log(grid.words)

        selected.addClass('solved')
        $(this).addClass('solved')

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
