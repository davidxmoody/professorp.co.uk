module.exports = class Card
  constructor: (@image) ->
    @_matched = false
    @$card = $('<div class="memory-card"></div>')

    $front = $('<div class="front"></div>')
    $front.css('background-image', "url(#{@image})")
    $front.appendTo(@$card)

    $back = $('<div class="back"></div>')
    $back.appendTo(@$card)

  tryMatch: (card) ->
    @_matched = card.image is @image
    card._matched = @_matched

  isMatched: ->
    @_matched

  hide: ->
    @$card.removeClass('faceup')

  show: ->
    @$card.addClass('faceup')
