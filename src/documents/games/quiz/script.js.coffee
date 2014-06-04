module.exports = class QuestionLoader
  constructor: ($container, @maxQuestions=10, @time=121, shuffle=true, @questions=defaultQuestions) ->
    @questions = _.shuffle(@questions) if shuffle
    @$qsContainer = $('<div class="questions-container"></div>')
    @$timer = $('<div class="timer"></div>')
    @$timer.appendTo(@$qsContainer)
    @$qsContainer.appendTo($container)

    @_countdownSecond()

    that = this
    @$qsContainer.on 'click', '.answer.correct:not(.selected)', ->
      $(this).addClass('selected')
      advance = -> that._nextQuestion()
      setTimeout(advance, 400)
    @$qsContainer.on 'click', '.answer:not(.correct):not(.selected)', ->
      $(this).addClass('selected')
      that._updateTimer(-20)
    @_nextQuestion()


  _nextQuestion: ->
    @questionIndex = (if @questionIndex? then @questionIndex+1 else 0)
    if @questionIndex >= @maxQuestions-1
      @_questionsCompleted()
    else
      @_loadQuestion(@questions[@questionIndex])


  _loadQuestion: (question) ->
    @$qsContainer.children('.question-container').remove()
    @$qsContainer.append(questionsTemplate(question))


  _updateTimer: (difference=0) ->
    return if @time is 0  # return if the game has already ended
    @time += difference
    @time = 0 if @time<0
    minutes = Math.floor(@time/60)
    seconds = @time%60
    seconds = '0'+seconds if seconds<10
    @$timer.text("#{minutes}:#{seconds}")
    if @time is 0
      @_timeUp()


  _countdownSecond: =>
    # return if game is over, TODO could do this better
    return if @questionIndex >= @maxQuestions-1
    @_updateTimer(-1)
    if @time > 0
      setTimeout(@_countdownSecond, 1000)


  _timeUp: ->
    @$qsContainer.off('click')
    alert("Time is up!")


  _questionsCompleted: ->
    @$qsContainer.off('click')
    alert("You won!")
