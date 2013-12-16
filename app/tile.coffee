SLIDING_DURATION = 150

class Vector
  constructor: (@x, @y) ->
  abs: -> Math.abs(@x) + Math.abs(@y)
  rev: -> new Vector(-@x, -@y)


module.exports = class Tile
  constructor: (@origX, @origY, @width, @height, @level) ->
    @x = origX
    @y = origY

    if level.emptyTile?
      @empty = origX is level.emptyTile[0] and origY is level.emptyTile[1]
    else
      @empty = origX is level.gridSize[0]-1 and origY is level.gridSize[1]-1

    @$tile = $ '<div/>'
    @$tile.css
      position: 'absolute'
      margin: '1px'
      width: width-2
      height: height-2
      left: origX*width
      top: origY*height
      'background-image': "url(#{level.image})"
      'background-size': "#{width*level.gridSize[0]}px #{height*level.gridSize[1]}px"
      'background-position': "#{-1*width*origX-1}px #{-1*height*origY-1}px"

    @$tile.css 'display', 'none' if @empty


  correctlyPlaced: ->
    @x is @origX and @y is @origY


  adjacentTo: (tile) ->
    @vectorTo(tile).abs() == 1


  swapWith: (tile, callback) ->
    vector = @vectorTo(tile)
    @_move(vector, callback)
    tile._move(vector.rev(), null)


  _move: (vector, callback) ->
    @x += vector.x
    @y += vector.y

    animation =
      left: '+='+@width*vector.x
      top: '+='+@height*vector.y

    @$tile.animate animation, SLIDING_DURATION, ->
      callback?(true)


  vectorTo: (tile) ->
    new Vector(tile.x-this.x, tile.y-this.y)
