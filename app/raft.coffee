module.exports = class Raft
  constructor: (@$raft) ->
    @position = 0

  move: (distance) ->
    @position += distance
    @$raft.css({left: "+=#{distance}px"})
