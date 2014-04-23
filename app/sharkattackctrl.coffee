sharkAttackApp = angular.module('sharkAttackApp', [])

class Shark
  constructor: (@left, @top, @velocityX, @velocityY) ->
    @initialLeft = @left

  updatePosition: ->
    @left += @velocityX
    @top += @velocityY

  getStyle: ->
    { left: "#{Math.floor(@left)}px", top: "#{Math.floor(@top)}px" }

  getClasses: ->
    [
      "frame#{Math.min(7, Math.floor(Math.abs(@left-@initialLeft)/10))}"
      if @velocityX<0 then 'left' else 'right'
    ]


sharkAttackApp.controller 'SharkAttackCtrl', ($scope) ->

  #TODO make these do something
  $scope.width = 800
  $scope.height = 500

  $scope.sharks = [
    new Shark(100, 100, 1, 0.5)
    new Shark(200, 200, -1, 0.1)
  ]

  $scope.moveSharks = ->
    for shark in $scope.sharks
      shark.updatePosition()
    $scope.$apply()

  setInterval($scope.moveSharks, 10)

  $scope.spawnShark = (x, y) ->
    x = _.random(100, $scope.width-100) unless x?
    y = _.random(100, $scope.height-100) unless y?
    velX = if x<$scope.width/2 then 1 else -1
    velY = 1
    $scope.sharks.push(new Shark(x, y, velX, velY))

  setInterval($scope.spawnShark, 1000)
