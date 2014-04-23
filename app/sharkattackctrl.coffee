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

  isOutOfBounds: ->
    #TODO should really use the width and height in $scope
    @left<-100 or @left>500 or @top<-100 or @top>500


sharkAttackApp.controller 'SharkAttackCtrl', ($scope) ->

  #TODO make these do something
  $scope.width = 400
  $scope.height = 400

  $scope.sharks = [
    new Shark(100, 100, 1, 0.5)
    new Shark(200, 200, -1, 0.1)
  ]

  $scope.moveSharks = ->
    for shark in $scope.sharks
      shark.updatePosition()
    $scope.sharks = _.filter($scope.sharks, (shark) -> not shark.isOutOfBounds())
    $scope.$apply()

  setInterval($scope.moveSharks, 10)

  $scope.spawnShark = (x, y) ->
    x = _.random(40, $scope.width-40) unless x?
    y = _.random(100, $scope.height-250) unless y?
    speed = 0.5+Math.random()
    velX = if x<$scope.width/2 then speed else -1*speed
    velY = speed
    $scope.sharks.push(new Shark(x, y, velX, velY))

  setInterval($scope.spawnShark, 500)
