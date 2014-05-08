$ = require('jquery')
_ = require('underscore')
MemoryGrid = require('./memorygrid')

$(document).ready ->
  grid = new MemoryGrid($('#container'))
