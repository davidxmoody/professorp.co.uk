fs     = require('fs')
stitch = require('stitch')
path   = require('path')
_      = require('underscore')
spawn  = require('child_process').spawn

APP_PATH = './app'
LIB_PATH = './lib'
JQUERY_FILE = path.join(LIB_PATH, 'jquery-1.11.0.min.js')
UNDERSCORE_FILE = path.join(LIB_PATH, 'underscore-1.6.0.min.js')
OUTPUT_SCRIPT = './script.js'

CSS_PATH = './stylesheets'
INPUT_CSS = path.join(CSS_PATH, 'main.scss')
OUTPUT_CSS = './stylesheet.css'


task 'build:css', "Build #{OUTPUT_CSS} from #{CSS_PATH}", ->
  spawn('sass', ['--update', "#{INPUT_CSS}:#{OUTPUT_CSS}"], {stdio: 'inherit'})

task 'watch:css', "Build #{OUTPUT_CSS} from #{CSS_PATH} whenever the sources change", ->
  spawn('sass', ['--watch', "#{INPUT_CSS}:#{OUTPUT_CSS}"], {stdio: 'inherit'})


task 'build:app', "Build #{OUTPUT_SCRIPT} from #{APP_PATH}", ->
  pkg = stitch.createPackage
    paths: [APP_PATH]
    dependencies: [JQUERY_FILE, UNDERSCORE_FILE]

  pkg.compile (err, source) ->
    fs.writeFile OUTPUT_SCRIPT, source, (err) ->
      throw err if err
      console.log('rebuilt app')

getSubdirs = (dir) ->
  dirs = [dir]
  for file in fs.readdirSync(dir)
    if fs.statSync(path.join(dir, file)).isDirectory()
      for subdir in getSubdirs(path.join(dir, file))
        dirs.push(subdir)
  dirs

watchHandler = (event, filename) ->
  #console.log(event, filename)
  invoke('build:app')
watchHandler = _.throttle(watchHandler, 50, {leading: false})

task 'watch:app', "Build #{OUTPUT_SCRIPT} from #{APP_PATH} whenever the sources change", ->
  for dir in getSubdirs(APP_PATH)
    fs.watch(dir, watchHandler)


task 'build', 'Run all builds', ->
  invoke('build:app')
  invoke('build:css')

task 'watch', 'Run all builds whenever the sources change', ->
  invoke('watch:app')
  invoke('watch:css')
