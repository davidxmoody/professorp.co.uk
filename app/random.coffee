module.exports = class Random
  constructor: (@seed) ->
    @seed ?= Math.random()

  choose: (array) ->
    x = Math.abs(Math.sin(@seed++))*10000
    x = x - Math.floor(x)
    index = Math.floor(x*array.length)
    array[index]

  clone: ->
    new Random(@seed)
