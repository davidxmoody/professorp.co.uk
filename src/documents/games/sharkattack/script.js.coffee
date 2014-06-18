if window.performance? and window.performance.now?
  timestamp = -> window.performance.now()
else
  timestamp = -> (new Date()).getTime()

class Entity
  constructor: (@x, @y, @velocityX, @velocityY) ->
    @initialX = @x
    @initialY = @y

  updatePosition: ->
    @x += @velocityX
    @y += @velocityY

  getStyle: ->
    { left: "#{@x}px", top: "#{@y}px" }

  getClasses: ->
    [ "none" ]


class Shark extends Entity
  constructor: (x, y, velocityX, velocityY) ->
    @hasAttacked = false
    super(x, y, velocityX, velocityY)

  getClasses: ->
    [
      "frame#{Math.min(7, Math.floor(Math.abs(@x-@initialX)/10))}"
      if @velocityX<0 then 'left' else 'right'
    ]

  isOutOfBounds: ->
    #TODO should really use the width and height in $scope
    @x<-100 or @x>500 or @y<-100 or @y>500


class Raft extends Entity
  constructor: (@hp=3, x=190, y=350, @maxHorizontalSpeed=2, @forwardSpeed=0.4) ->
    @damage = 0
    super(x, y, 0, -1*@forwardSpeed)

  updatePosition: (goLeft, goRight) ->
    unless @damage>=@hp
      if goLeft and not goRight
        @velocityX = -1*@maxHorizontalSpeed
      else if goRight and not goLeft
        @velocityX = @maxHorizontalSpeed
      else
        @velocityX = 0
      super()
  
  getClasses: ->
    [
      "frame#{Math.min(@damage, 2)}"
      if @damage>=@hp then 'destroyed'
    ]

  takeBite: ->
    @damage++
    if @damage==@hp
      alertEaten = ->
        alert 'You got eaten!'
      setTimeout(alertEaten, 2000)


angular.module('sharkAttackApp', []).controller('SharkAttackCtrl', ['$scope', ($scope) ->

  # Game balance variables
  $scope.fastSharkChance = 0.3
  $scope.sharksPerSecond = 3.0
  $scope.raftHitPoints = 3

  $scope.width = 400
  $scope.height = 400

  $scope.goLeft = false
  $scope.goRight = false

  $scope.raft = new Raft($scope.raftHitPoints)
  $scope.sharks = []
  $scope.updatesUntilNextShark = 0

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
        if shark.y-20 < $scope.raft.y < shark.y+20 and \
           shark.x-20 < $scope.raft.x < shark.x+20
          shark.hasAttacked = true
          $scope.raft.takeBite()

    # Then spawn extra sharks
    $scope.updatesUntilNextShark--
    if $scope.updatesUntilNextShark <= 0
      $scope.spawnShark()
      $scope.updatesUntilNextShark = 1/$scope.sharksPerSecond/$scope.step


  # Called once per animation frame, will update the game model as many times
  # as necessary before allowing it to be drawn to the screen
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
    if Math.random()<$scope.fastSharkChance
      speed = 2
      verticalDistanceFromRaft = 100+Math.random()*80
      timeToCollision = verticalDistanceFromRaft/(speed+$scope.raft.forwardSpeed)
      direction = if $scope.raft.x<$scope.width/2 then 1 else -1
      yDiff = timeToCollision*speed
      xDiff = timeToCollision*speed*direction
      y = $scope.raft.y-yDiff
      x = $scope.raft.x-xDiff
      if y>50
        $scope.sharks.push(new Shark(x, y-20, speed*direction, speed))

    else
      # Choose random position and speed
      x = _.random(20, $scope.width-20)
      y = _.random(50, $scope.height-250)
      speed = 0.5+Math.random()

      # Move its position if it is too close to the raft
      if 0 < $scope.raft.x-x < 20 and -20 < $scope.raft.y-y < 20
        x -= 40
      if -20 < $scope.raft.x-x < 0 and -20 < $scope.raft.y-y < 20
        x += 40

      # Set the velocity to make the shark travel towards the center of the map
      velX = if x<$scope.width/2 then speed else -1*speed
      velY = speed

      $scope.sharks.push(new Shark(x, y, velX, velY))


  # Keep track of whether the left and right arrow keys are down
  $scope.keyevent = ($event) ->
    keydown = $event.type is 'keydown'
    switch $event.which
      when 37 then $scope.goLeft = keydown
      when 39 then $scope.goRight = keydown
])
