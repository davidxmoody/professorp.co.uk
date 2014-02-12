startEverything = ->
  console.log 'hello world'


module.exports = App =
  init: ->
    $(document).ready ->
      startEverything()
