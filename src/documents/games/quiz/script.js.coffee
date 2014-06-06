#TODO use browserify and require statement

introQuestion = {
  text: "Are you ready to begin?"
  answers: [ { text: "Yes", isCorrect: true }, { text: "No" } ]
}

youWonQuestion = {
  text: "Congratulations!"
  answers: [ { text: "Play again", isCorrect: true } ]
}

youLostQuestion = {
  text: "You lost, better luck next time!"
  answers: [ { text: "Play again", isCorrect: true } ]
}

angular.module('quizGame', []).controller 'QuizCtrl', ($scope, $timeout) ->

  # Game config options
  $scope.numQuestions = 20
  $scope.numAnswered = 0
  $scope.questions = window.getQuestions($scope.numQuestions)
  $scope.currentQuestion = introQuestion
  $scope.secondsRemaining = 120
  $scope.penalty = 10

  # Update time remaining and trigger end game if time is up
  $scope.updateTimer = (difference) ->
    $scope.secondsRemaining += difference
    if $scope.secondsRemaining <= 0
      $scope.secondsRemaining = 0
      $timeout($scope.nextQuestion, 400)

  # Helper function for formatting the seconds remaining
  $scope.formatTime = (time) ->
    minutes = Math.floor(time/60)
    seconds = time%60
    seconds = '0'+seconds if seconds<10
    "#{minutes}:#{seconds}"

  $scope.nextQuestion = ->
    # Game has been won
    if $scope.numQuestions == $scope.numAnswered
      $scope.currentQuestion = youWonQuestion

    # Game has been lost
    else if $scope.secondsRemaining <= 0
      $scope.currentQuestion = youLostQuestion

    # Game still in progress
    else
      $scope.currentQuestion = $scope.questions.shift()

  $scope.submitAnswer = (answer) ->
    if answer.text == "Play again"
      #TODO do this without forcing a page refresh
      location.reload()

    unless answer.isSelected or answer.isDisabled
      answer.isSelected = true

      # If asking if you are ready to begin and answer yes then begin
      if $scope.currentQuestion is introQuestion
        if answer.isCorrect
          $timeout($scope.nextQuestion, 400)
          $timeout(countdownSecond, 1000)

      else
        if answer.isCorrect
          # Disable other answers and proceed to next question
          for otherAnswer in $scope.currentQuestion.answers
            otherAnswer.isDisabled = true if otherAnswer isnt answer
          $scope.numAnswered++
          $timeout($scope.nextQuestion, 400)
        else
          # Subtract penalty but continue game
          $scope.updateTimer(-1*$scope.penalty)

  countdownSecond = ->
    # Cancel countdown if game is over
    return if $scope.secondsRemaining <= 0 or $scope.numQuestions == $scope.numAnswered
    $scope.updateTimer(-1)
    $timeout(countdownSecond, 1000)
