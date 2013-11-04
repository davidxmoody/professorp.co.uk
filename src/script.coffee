# MODEL #######################################################################

# classes required in models: 
#   Level - what tiles to present to the user
#   Grid - container of multiple tiles, information on state of all tiles together
#   Tile - one tile, can be toggled, compared to other tiles
#   Move - one logical action taken by the user *is this needed?*

class Level
  constructor: (@images, @back) ->

LEVELS = [
  new Level([
    "images/Image0.jpg"
    "images/Image1.jpg"
    "images/Image2.jpg"
    "images/Image3.jpg"
    "images/Image4.jpg"
    "images/Image8.jpg"
  ], "images/back.gif")
]


class Card
  constructor: (@image) ->

  matches: (card) -> card.image is @image


class MemoryGame
  constructor: (@level) ->
    @cards = (new Card(image, level.back) for image in level.images+level.images)



class MemoryGrid
  constructor: (@level, $container, maxWidth, maxHeight) ->
    @TILE_FLIP_DURATION = 50
    @movesTaken = 0
    @allowInput = false

    @$selectedTile1 = null
    @$selectedTile2 = null
    
    @$grid = $ '<div/>'
    @$grid.css 'position', 'relative'
    @$grid.css 'border', '1px black solid'
    @$grid.css 'display', 'inline-block'
    @$grid.width maxWidth
    @$grid.height maxHeight

    @tiles = (for i in [0..level.images.length*2-1]
      $tile = $ '<div/>'
      $tile.css 'margin-top', '20px'
      $tile.css 'margin-left', '20px'
      $tile.css 'display', 'inline-block'
      $tile.css 'border-radius', '2px'

      $tile.width 100
      $tile.height 100

      $tile.data 'front', 'url('+level.images[Math.floor(i/2)]+')'
      $tile.data 'back', 'url('+level.back+')'
      $tile.data 'state', 'hidden'

      $tile.css 'background-image', $tile.data('back')
      $tile.css 'background-size', '100% 100%'

      thisGrid = this
      $tile.click -> thisGrid._toggleTile $(this) if thisGrid.allowInput

      @$grid.append $tile
      $tile
    )

    # Shuffle tiles around a bit
    for i in [1..100]
      randomTiles = (@tiles[Math.floor(Math.random()*@tiles.length)] for i in [1..2])
      randomTiles[0].after randomTiles[1]

    $container.append @$grid

  start: (@completeCallback) ->
    @allowInput = true

  destroy: ->

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

    @movesTaken++

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


$(document).ready ->
  memoryGrid = new MemoryGrid(LEVELS[0], $("#container"), 500, 390)
  memoryGrid.start(null)
