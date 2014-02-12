SharkGameTemplate = require('sharkgametemplate')

module.exports = class SharkGame
  constructor: (@$container) ->
    @$game = $(SharkGameTemplate())
    @$container.append(@$game)
    @$raft = @$game.find('.raft')

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


  step: =>
    if @goLeft and not @goRight
      @$raft.css({left: '-=10px'})

    else if @goRight and not @goLeft
      @$raft.css({left: '+=10px'})



  start: ->
    setInterval(@step, 20)
