questions = require('questions')
questionsTemplate = require('questionstemplate')

module.exports = App =
  init: ->
    $(document).ready ->
      $question = questionsTemplate(questions[0])
      $('#container').append($question)
