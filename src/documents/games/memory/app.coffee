$ = require('jquery')
MemoryGrid = require('./memorygrid')

$(document).ready ->
  grid = new MemoryGrid($('#container'))
