stitch = require 'stitch'
fs = require 'fs'

#TODO add a file timestamp check so this is done every time 
# wordlist.txt is newer than the generated file
task 'wordlist', 'Build lib/wordlist.js from wordlist.txt', ->
  words = fs.readFileSync 'wordlist.txt', 'utf-8'
  wordlist = words.split('\n')
  wordlist = (word.toUpperCase() for word in wordlist when \
                 word.length>0 and word.charAt(0) isnt '#')
  wordlist.sort (a, b) -> b.length-a.length # Sort with descending length
  fs.writeFile 'app/wordlist.js', "module.exports = #{JSON.stringify(wordlist)};"


task 'build', 'Build script.js from /app', ->
  pkg = stitch.createPackage
    paths: [__dirname + '/app']
    dependencies: [__dirname + '/lib/jquery-1.11.0.min.js']

  pkg.compile (err, source) ->
    fs.writeFile 'script.js', source, (err) ->
      throw err if err
      console.log 'compiled script.js'
