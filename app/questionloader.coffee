defaultQuestions = require('questions')
questionsTemplate = require('questionstemplate')

module.exports = class QuestionLoader
  constructor: ($container, @maxQuestions=10, shuffle=false, @questions=defaultQuestions) ->
    @questions = _.shuffle(@questions) if shuffle
    @$qContainer = $('<div class="questions-container"></div>')
    @$qContainer.appendTo($container)
    @wrongAnswers = 0

    that = this
    @$qContainer.on 'click', '.answer.correct:not(.selected)', ->
      $(this).addClass('selected')
      advance = -> that._nextQuestion()
      setTimeout(advance, 400)
    @$qContainer.on 'click', '.answer:not(.correct):not(.selected)', ->
      $(this).addClass('selected')
      that.wrongAnswers++
      console.log("You have got #{that.wrongAnswers} answers wrong")
    @_nextQuestion()


  _nextQuestion: ->
    @questionIndex = (if @questionIndex? then @questionIndex+1 else 0)
    @_loadQuestion(@questions[@questionIndex])


  _loadQuestion: (question) ->
    @$qContainer.empty()
    @$qContainer.append(questionsTemplate(question))
