$ = require('jquery')
_ = require('underscore')
Card = require('./card')
getRandomImages = require('./getrandomimages')


module.exports = class MemoryGrid
  constructor: ($container, @callback, numCards=12, cardsPerRow=4) ->

    # Create empty grid to contain the cards
    @$grid = $('<div></div>')
    @$grid.addClass('memory-grid')

    # Create the cards
    @cards = []
    for image in getRandomImages(numCards/2)
      @cards.push(new Card(image))
      @cards.push(new Card(image))

    # Shuffle the cards
    @cards = _.shuffle(@cards)

    # Add cards to $grid and add click handler
    for card, i in @cards
      if i%cardsPerRow==0
        $row = $('<div></div>')
        $row.appendTo(@$grid)
      card.$card.appendTo($row)
      card.$card.click($.proxy(@_cardClicked, this, card))

    # No card is selected at first
    @selected = null

    # Make the grid visible
    @$grid.appendTo($container)


  _cardClicked: (card) ->
    # First clear any previous incorrect selections
    if @cardsToClear?
      for cardToClear in @cardsToClear
        cardToClear.hide()
      @cardsToClear = null

    # Case 1: Clicked on a hidden card and no card already selected
    if not card.isMatched() and not @selected?
      card.show()
      @selected = card

    # Case 2: Clicked on a hidden card and another (different) card is already selected
    else if not card.isMatched() and @selected? and @selected isnt card
      card.show()
      matched = card.tryMatch(@selected)
      if not matched
        @cardsToClear = [card, @selected]
      @selected = null

      # Check for completion
      if _.every(@cards, (card) -> card.isMatched())
        @_gameCompleted()

    # Case 3: Clicked on a matched card or the currently selected card
    # Do nothing


  _gameCompleted: ->
    alert 'Congratulations, you matched all of the cards!'
    @callback?()
