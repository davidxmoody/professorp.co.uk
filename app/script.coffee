Card = require('card')

class Level
  constructor: (@images, @back) ->

LEVELS = [
  new Level([
    "images/image0.jpg"
    "images/image1.jpg"
    "images/image2.jpg"
    "images/image3.jpg"
    "images/image4.jpg"
    "images/image8.jpg"
  ], "images/back.gif")
]


class MemoryGrid
  constructor: (@level, $container, maxWidth, maxHeight) ->
    @$selectedTile1 = null
    @$selectedTile2 = null
    
    @$grid = $ '<div/>'
    @$grid.addClass('grid')
    @$grid.width maxWidth
    @$grid.height maxHeight

    @tiles = (for i in [0..level.images.length*2-1]
      $tile = $ '<div/>'
      $tile.addClass('tile')

      $tile.data 'front', 'url('+level.images[Math.floor(i/2)]+')'
      $tile.data 'back', 'url('+level.back+')'
      $tile.data 'state', 'hidden'

      $tile.css 'background-image', $tile.data('back')

      thisGrid = this
      #TODO delegate to parent grid
      $tile.click -> thisGrid._toggleTile $(this)

      @$grid.append $tile
      $tile
    )

    # Shuffle tiles around a bit
    for i in [1..100]
      randomTiles = (@tiles[Math.floor(Math.random()*@tiles.length)] for i in [1..2])
      randomTiles[0].after randomTiles[1]

    $container.append @$grid

  _toggleTile: ($tile) ->
    return if $tile.data('state') isnt 'hidden'
    
    # If two incorrectly matched tiles were last selected then hide them
    if @$selectedTile1? and @$selectedTile2?
      @_hideTile @$selectedTile1
      @_hideTile @$selectedTile2
      @$selectedTile1 = null
      @$selectedTile2 = null

    # If no tiles previously selected then show this one
    if not @$selectedTile1? and not @$selectedTile2?
      @_showTile $tile
      @$selectedTile1 = $tile

    # If one tile was previously selected then show this one and check for a match
    else
      @_showTile $tile
      @$selectedTile2 = $tile

      if @$selectedTile1.data('front') is @$selectedTile2.data('front')
        @$selectedTile1.data 'state', 'solved'
        @$selectedTile2.data 'state', 'solved'
        @$selectedTile1 = null
        @$selectedTile2 = null

  _hideTile: ($tile) ->
    $tile.css 'background-image', $tile.data 'back'
    $tile.data 'state', 'hidden'

  _showTile: ($tile) ->
    $tile.css 'background-image', $tile.data 'front'
    $tile.data 'state', 'shown'
        
  _numIncorrect: ->
    count = 0
    for $tile in @tiles
      count++ if $tile.data 'state' is 'solved'
    count

  _cardClicked: (card) ->
    #TODO


module.exports.startEverything = ->
  memoryGrid = new MemoryGrid(LEVELS[0], $("#container"), 500, 390)
