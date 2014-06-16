$ = require 'jquery'

module.exports = class AIPersonality
  constructor: (@name) ->

  say: (html) ->
    $('#ai-speech').html("<strong>#{@name}:</strong> #{html}")

  randomSay: (htmls...) ->
    html = htmls[Math.floor(Math.random()*htmls.length)]
    @say(html)
