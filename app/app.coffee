LetterGrid = require 'lettergrid'

module.exports = App =
  init: ->
    $(document).ready ->
      grid = new LetterGrid($('#container'))
