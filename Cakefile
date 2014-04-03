fs     = require('fs')
stitch = require('stitch')
path   = require('path')
_      = require('underscore')

APP_PATH = path.resolve('./app')
LIB_PATH = path.resolve('./lib')
JQUERY_FILE = path.join(LIB_PATH, 'jquery-1.11.0.min.js')


task 'build', 'Build script.js from /app', ->
  pkg = stitch.createPackage
    paths: [APP_PATH]
    dependencies: [JQUERY_FILE]

  pkg.compile (err, source) ->
    fs.writeFile 'script.js', source, (err) ->
      throw err if err
      console.log('compiled script.js')


getSubdirs = (dir) ->
  dirs = [dir]
  for file in fs.readdirSync(dir)
    if fs.statSync(path.join(dir, file)).isDirectory()
      for subdir in getSubdirs(path.join(dir, file))
        dirs.push(subdir)
  dirs


watchHandler = (event, filename) ->
  console.log(event, filename)
  invoke('build')
watchHandler = _.throttle(watchHandler, 50, {leading: false})


task 'watch', 'Run appropriate build whenever the relevant files change', ->
  for dir in getSubdirs(APP_PATH)
    fs.watch(dir, watchHandler)
