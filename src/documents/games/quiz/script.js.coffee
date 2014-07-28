---
browserify: true
---

angular = require 'angular'
getQuestions = require './questions'

angular.module('quizGame', []).controller 'QuizCtrl', ($scope, $timeout) ->

  $scope.levels = [
    { description: 'Inventions from book 1 (easy)', category: 'inventionsBook1', numQuestions: 15, totalSeconds: 120, penalty: 10 }
    { description: 'Inventions from book 1 (hard)', category: 'inventionsBook1', numQuestions: 20, totalSeconds: 120, penalty: 15 }
    #{ description: 'Dinosaurs (easy)', category: 'dinosaurs', numQuestions: 15, totalSeconds: 120, penalty: 10 }
  ]

  # Load the specified question set
  $scope.loadLevel = (level) ->
    $scope.lastLevel = level
    $scope.questions = getQuestions(level.category, level.numQuestions)
    $scope.numQuestions = $scope.questions.length
    $scope.numAnswered = 0
    $scope.totalSeconds = level.totalSeconds
    $scope.secondsRemaining = $scope.totalSeconds
    $scope.penalty = level.penalty
    $scope.stopTimer = true
    $scope.currentQuestion = {
      text: "Are you ready to begin?"
      answers: [ { text: "Yes", isCorrect: true }, { text: "No" } ]
      isIntroQuestion: true
    }

  # Load the first level by default
  $scope.loadLevel($scope.levels[0])


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
      $scope.currentQuestion = {
        text: "You won, congratulations!"
        answers: [ { text: "Play again", isCorrect: true } ]
        isPlayAgainQuestion: true
      }

    # Game has been lost
    else if $scope.secondsRemaining <= 0
      $scope.currentQuestion = {
        text: "Time up, better luck next time!"
        answers: [ { text: "Play again", isCorrect: true } ]
        isPlayAgainQuestion: true
      }

    # Game still in progress
    else
      $scope.currentQuestion = $scope.questions.shift()


  # An answer has been clicked
  $scope.submitAnswer = (answer) ->
    unless answer.isSelected or answer.isDisabled
      answer.isSelected = true

      # If asking if you are ready to begin and answer "Yes" then begin
      if $scope.currentQuestion.isIntroQuestion and answer.isCorrect
        $scope.stopTimer = false
        $timeout($scope.nextQuestion, 400)
        $timeout(countdownSecond, 1000)

      # If asking if you want to play again and answer "Play again" then restart
      else if $scope.currentQuestion.isPlayAgainQuestion and answer.isCorrect
        restart = ->
          $scope.loadLevel($scope.lastLevel)
        $timeout(restart, 400)

      # If correct answer to a regular question
      else if answer.isCorrect
        # Disable other answers and proceed to next question after a delay
        for otherAnswer in $scope.currentQuestion.answers
          otherAnswer.isDisabled = true if otherAnswer isnt answer
        $scope.numAnswered++
        $timeout($scope.nextQuestion, 400)

      # If incorrect answer to a regular question
      else
        # Subtract penalty but continue game
        $scope.updateTimer(-1*$scope.penalty)

  countdownSecond = ->
    # Cancel countdown if game is over or has been restarted
    return if $scope.secondsRemaining <= 0 or $scope.numQuestions == $scope.numAnswered or $scope.stopTimer
    $scope.updateTimer(-1)
    $timeout(countdownSecond, 1000)
