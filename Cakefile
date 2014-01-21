fs = require 'fs'

#TODO add a file timestamp check so this is done every time 
# wordlist.txt is newer than the generated file
task 'wordlist', 'Build lib/wordlist.js from wordlist.txt', ->
  words = fs.readFileSync 'wordlist.txt', 'utf-8'
  wordList = words.split('\n')
  wordList = (word for word in wordList when word.length>0 and
                                             word.charAt(0) isnt '#')
  #TODO sort the list by length?
  fs.writeFile 'lib/wordlist.js', "module.exports = #{JSON.stringify(wordList)};"
