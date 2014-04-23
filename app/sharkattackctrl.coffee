sharkAttackApp = angular.module('sharkAttackApp', [])

class Shark
  constructor: (@left, @top) ->
    @initialLeft = @left

  getStyle: ->
    { left: "#{@left}px", top: "#{@top}px" }

  getFrameClass: ->
    "frame#{Math.floor(((@left-@initialLeft)/20)%8)}"

sharkAttackApp.controller 'SharkAttackCtrl', ($scope) ->

  $scope.sharks = [
    new Shark(100, 100)
    new Shark(200, 200)
  ]

  $scope.moveSharks = ->
    for shark in $scope.sharks
      shark.left += 1
    $scope.$apply()

  setInterval($scope.moveSharks, 5)
