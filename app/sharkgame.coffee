SharkGameTemplate = require('sharkgametemplate')
Raft = require('raft')

# Note: may not work on older browsers, check that
timestamp = -> window.performance.now()

module.exports = class SharkGame
  constructor: (@$container) ->
    @$game = $(SharkGameTemplate())
    @$container.append(@$game)
    @raft = new Raft(@$game.find('.raft'))

    @goLeft = false
    @goRight = false

    $(document).keydown(@keydown)
    $(document).keyup(@keyup)


  keydown: (event) =>
    keycode = event.which
    if keycode is 37
      @goLeft = true
    else if keycode is 39
      @goRight = true


  keyup: (event) =>
    keycode = event.which
    if keycode is 37
      @goLeft = false
    else if keycode is 39
      @goRight = false


  update: =>
    if @goLeft and not @goRight
      @raft.move(-10)

    else if @goRight and not @goLeft
      @raft.move(-10)


  render: =>


  frame: =>
    now = timestamp()
    @dt += Math.min(1, (now-@last)/1000)
    numUpdates = 0
    while @dt > @step
      @dt -= @step
      @update()
      numUpdates++
    #TODO remove this numUpdates checking code
    console.log "numUpdates = #{numUpdates}" if numUpdates isnt 1
    #TODO only render when necessary
    @render()
    @last = now
    requestAnimationFrame(@frame)


  start: ->
    @dt = 0
    @last = timestamp()
    @step = 1/60
    requestAnimationFrame(@frame)
