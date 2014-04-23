sharkAttackApp = angular.module('sharkAttackApp', [])

class Shark
  constructor: (@left, @top) ->

  getStyle: ->
    { left: "#{@left}px", top: "#{@top}px" }

sharkAttackApp.controller 'SharkAttackCtrl', ($scope) ->

  $scope.sharks = [
    new Shark(100, 100)
    new Shark(200, 200)
  ]

  $scope.shark = $scope.sharks[0]

  $scope.$watch 'shark', ->
    console.log 'watched'

  $scope.moveSharks = ->
    for shark in $scope.sharks
      shark.left += 1
    $scope.$apply()

  setInterval($scope.moveSharks, 5)
