module.exports = class Card
  constructor: (@image) ->
    @_matched = false
    @$card = $('<div></div>')
    @$card.addClass('memory-card')
    @$card.css('background-image', "url(#{@image})")

  tryMatch: (card) ->
    @_matched = card.image is @image

  isMatched: ->
    @_matched

  hide: ->
    @$card.removeClass('faceup')

  show: ->
    @$card.addClass('faceup')
