spawn = require('child_process').spawn
fs = require('fs')

task 'build:wordlist', 'Build lib/wordlist.js from wordlist.txt', ->
  words = fs.readFileSync('wordlist.txt', 'utf-8')
  wordlist = words.split('\n')
  wordlist = (word.toUpperCase() for word in wordlist when \
                 word.length>0 and word.charAt(0) isnt '#')
  wordlist.sort((a, b) -> b.length-a.length)  # Sort with descending length
  fs.writeFile 'lib/wordlist.js', "defaultWordlist = #{JSON.stringify(wordlist)};"

task 'build', 'Compile all app/*.coffee to the equivalent lib/*.js', ->
  #TODO add some kind of feedback to the terminal
  spawn('coffee', ['-c', '-o', 'lib', 'app'])

task 'watch', 'Compile all app/*.coffee to the equivalent lib/*.js whenever the source files change', ->
  spawn('coffee', ['-w', '-c', '-o', 'lib', 'app'])
