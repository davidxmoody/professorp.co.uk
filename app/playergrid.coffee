ShuffleGrid = require 'shufflegrid'

module.exports = class PlayerGrid extends ShuffleGrid
  start: (@completionCallback) ->
    @_randomShuffle @_enableInput

    thisGrid = this
    @$grid.on 'click', '.tile', ->
      return unless thisGrid.allowInput
      thisGrid._disableInput()
      thisGrid._tryMoveTile $(this), (moved) ->
        if moved and thisGrid._numIncorrect() is 0
          thisGrid._gridCompleted()
        else
          thisGrid._enableInput()


  _disableInput: =>
    @allowInput = false


  _enableInput: =>
    @allowInput = true
