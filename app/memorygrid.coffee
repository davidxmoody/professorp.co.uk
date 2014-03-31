Card = require('card')
getRandomImages = require('getrandomimages')

module.exports = class MemoryGrid
  constructor: ($container, numCards=12) ->

    # Create empty grid to contain the cards
    @$grid = $('<div></div>')
    @$grid.addClass('memory-grid')

    # Create the cards
    @cards = []
    for image in getRandomImages(numCards/2)
      @cards.push(new Card(image))
      @cards.push(new Card(image))

    # Shuffle the cards
    for i in [1..numCards*10]
      index1 = Math.floor(Math.random()*@cards.length)
      index2 = Math.floor(Math.random()*@cards.length)
      [@cards[index1], @cards[index2]] = [@cards[index2], @cards[index1]]

    # Add cards to $grid and add click handler
    for card in @cards
      card.$card.appendTo(@$grid)
      card.$card.click($.proxy(@_cardClicked, this, card))

    # No card is selected at first
    @selected = null

    # Make the grid visible
    @$grid.appendTo($container)


  _cardClicked: (card) ->
    # Case 1: Clicked on a hidden card and no card already selected
    #TODO finish this method
    if not card.isMatched() and not @selected?
      card.show()
      @selected = card

    else if not card.isMatched() and @selected?
      card.show()
