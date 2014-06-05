#TODO use browserify and require statement
#TODO require underscore

questions = window.profpQuestions
introQuestion = window.profpIntroQuestion

angular.module('quizGame', []).controller 'QuizCtrl', ($scope, $timeout) ->
  $scope.secondsRemaining = 120
  $scope.currentQuestion = introQuestion

  $scope.updateTimer = (difference) ->
    $scope.secondsRemaining += difference
    $scope.secondsRemaining = 0 if $scope.secondsRemaining < 0
    if $scope.secondsRemaining == 0
      console.log 'time up'
      #TODO end game

  $scope.formatTime = (time) ->
    minutes = Math.floor(time/60)
    seconds = time%60
    seconds = '0'+seconds if seconds<10
    "#{minutes}:#{seconds}"

  $scope.nextQuestion = ->
    $scope.currentQuestion = questions.shift()

  $scope.submitAnswer = (answer) ->
    unless answer.isSelected or $scope.secondsRemaining <= 0
      answer.isSelected = true
      if answer.isCorrect
        $timeout($scope.nextQuestion, 400)
        $timeout(countdownSecond, 1000) if $scope.currentQuestion is introQuestion
      else
        $scope.updateTimer(-20) unless $scope.currentQuestion is introQuestion

  countdownSecond = ->
    return if $scope.secondsRemaining <= 0
    $scope.updateTimer(-1)
    $timeout countdownSecond, 1000
