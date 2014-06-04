QuestionLoader = require('questionloader')

module.exports = App =
  init: ->
    $(document).ready ->
      ql = new QuestionLoader($('#container'))
