MemoryGrid = require('memorygrid')

module.exports = App =
  init: ->
    $(document).ready ->
      grid = new MemoryGrid($('#container'))
