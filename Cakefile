spawn = require('child_process').spawn
fs = require('fs')

task 'build:wordlist', 'Build lib/wordlist.js from wordlist.txt', ->
  words = fs.readFileSync('wordlist.txt', 'utf-8')
  wordlist = words.split('\n')
  wordlist = (word.toUpperCase() for word in wordlist when \
                 word.length>0 and word.charAt(0) isnt '#')
  wordlist.sort((a, b) -> b.length-a.length)  # Sort with descending length
  fs.writeFile 'lib/wordlist.js', "defaultWordlist = #{JSON.stringify(wordlist)};"

build = (watch=false) ->
  args = ['-c', '-o', 'lib', 'app']
  args.unshift('-w') if watch
  coffee = spawn('coffee', args)
  coffee.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  coffee.stdout.on 'data', (data) ->
    console.log data.toString()

task 'build', 'Compile all app/*.coffee to the equivalent lib/*.js', ->
  build(false)

task 'watch', 'Compile all app/*.coffee to the equivalent lib/*.js whenever the source files change', ->
  build(true)
