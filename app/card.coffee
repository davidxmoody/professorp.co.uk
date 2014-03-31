module.exports = class Card
  constructor: (@image) ->
    @_matched = false
    @$card = $('<div></div>')
    @$card.addClass('memory-card')
    @$card.css('background-image', "url(#{@image})")

  matches: (card) ->
    card.image is @image
    @_matched = true

  isMatched: ->
    @_matched

  hide: ->
    @$card.removeClass('faceup')

  show: ->
    @$card.addClass('faceup')
