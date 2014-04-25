sharkAttackApp = angular.module('sharkAttackApp', [])

#TODO check this works everywhere
timestamp = -> window.performance.now()

class Shark
  constructor: (@left, @top, @velocityX, @velocityY) ->
    @initialLeft = @left
    @hasAttacked = false

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


class Raft
  constructor: (@left=190, @top=350) ->
    @damage = 0
    @forwardSpeed = 0.4

  updatePosition: (goLeft, goRight) ->
    if goLeft and not goRight
      @left += -2
    else if goRight and not goLeft
      @left += 2
    @top -= @forwardSpeed
  
  getStyle: ->
    { left: "#{Math.floor(@left)}px", top: "#{Math.floor(@top)}px" }

  getClasses: ->
    [
      "frame#{Math.min(@damage, 2)}"
    ]

  takeBite: ->
    @damage++
    if @damage>=3
      #TODO do this better
      console.log "You got eaten!"



sharkAttackApp.controller('SharkAttackCtrl', ['$scope', '$interval', ($scope, $interval) ->

  #TODO make these do something
  $scope.width = 400
  $scope.height = 400

  $scope.goLeft = false
  $scope.goRight = false

  $scope.raft = new Raft()

  $scope.sharks = []

  $scope.dt = 0
  $scope.last = timestamp()
  $scope.step = 1/60

  $scope.update = ->
    # Move raft first
    $scope.raft.updatePosition($scope.goLeft, $scope.goRight)

    # Then move sharks
    for shark in $scope.sharks
      shark.updatePosition()
    $scope.sharks = _.filter($scope.sharks, (shark) -> not shark.isOutOfBounds())

    # Then check to see if the raft collides with a shark
    for shark in $scope.sharks
      unless shark.hasAttacked
        if shark.top-20 < $scope.raft.top < shark.top+20 and \
           shark.left-20 < $scope.raft.left < shark.left+20
          shark.hasAttacked = true
          $scope.raft.takeBite()

  #TODO cancel this once the game is over, same for the other one too
  #$interval($scope.update, 10)

  $scope.frame = ->
    $scope.$apply ->
      now = timestamp()
      $scope.dt += Math.min(1, (now-$scope.last)/1000) # Prevent too many frames occurring at once
      while $scope.dt>$scope.step
        $scope.dt -= $scope.step
        $scope.update()
      $scope.last = now

  $scope.startLoop = ->
    $scope.frame()
    requestAnimationFrame($scope.startLoop)

  requestAnimationFrame($scope.startLoop)

  $scope.spawnShark = ->
    # Small chance to spawn a fast shark heading for the raft
    if Math.random()<0.2
      speed = 2
      verticalDistanceFromRaft = 100+Math.random()*80
      timeToCollision = verticalDistanceFromRaft/(speed+$scope.raft.forwardSpeed)
      direction = if $scope.raft.left<$scope.width/2 then 1 else -1
      yDiff = timeToCollision*speed
      xDiff = timeToCollision*speed*direction
      y = $scope.raft.top-yDiff
      x = $scope.raft.left-xDiff
      if y>50
        $scope.sharks.push(new Shark(x, y-20, speed*direction, speed))

    else
      #TODO prevent sharks from spawning directly on top of the raft
      x = _.random(20, $scope.width-40)
      y = _.random(50, $scope.height-250)
      speed = 0.5+Math.random()
      velX = if x<$scope.width/2 then speed else -1*speed
      velY = speed
      $scope.sharks.push(new Shark(x, y, velX, velY))

  setInterval($scope.spawnShark, 500)

  $scope.keyevent = ($event) ->
    keydown = $event.type is 'keydown'
    switch $event.which
      when 37 then $scope.goLeft = keydown
      when 39 then $scope.goRight = keydown
])
