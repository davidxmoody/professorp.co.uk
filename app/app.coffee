generateGrid = require 'generategrid'

startEverything = ->
  grid = generateGrid()

  $grid = $('<div/>')
  $grid.addClass('ws-grid')
  for y in [0..grid.height-1]
    $row = $('<div/>')
    $row.appendTo($grid)
    for x in [0..grid.width-1]
      $cell = $('<div/>')
      $cell.addClass('ws-cell')
      $cell.text(grid.grid[y][x])
      $cell.appendTo($row)

  $grid.appendTo($('#container'))
  $(".ws-cell").click ->
    $(this).toggleClass('selected')
  console.log grid.words


module.exports = App =
  init: ->
    $(document).ready ->
      startEverything()
