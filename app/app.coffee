old_script = require 'old-script'

module.exports = App =
  init: ->
    $(document).ready ->
      old_script.startEverything()
