stitch = require 'stitch'
fs = require 'fs'

task 'build', 'Build script.js from /app', ->
  pkg = stitch.createPackage
    paths: [__dirname + '/app']
    dependencies: [__dirname + '/lib/jquery-1.11.0.min.js']

  pkg.compile (err, source) ->
    fs.writeFile 'script.js', source, (err) ->
      throw err if err
      console.log 'compiled script.js'
