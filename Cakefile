stitch = require 'stitch'
fs = require 'fs'

#TODO add a file timestamp check so this is done every time 
# wordlist.txt is newer than the generated file
task 'wordlist', 'Build lib/wordlist.js from wordlist.txt', ->
  words = fs.readFileSync 'wordlist.txt', 'utf-8'
  wordList = words.split('\n')
  wordList = (word.toUpperCase() for word in wordList when \
                 word.length>0 and word.charAt(0) isnt '#')
  #TODO sort the list by length?
  fs.writeFile 'app/wordlist.js', "module.exports = #{JSON.stringify(wordList)};"


task 'build', 'Build script.js from /app', ->
  pkg = stitch.createPackage
    paths: [__dirname + '/app']
    dependencies: [__dirname + '/lib/jquery-1.11.0-beta2.js']

  pkg.compile (err, source) ->
    fs.writeFile 'script.js', source, (err) ->
      throw err if err
      console.log 'compiled script.js'
