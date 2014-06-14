gulp = require 'gulp'
gutil = require 'gulp-util'
watchify = require 'watchify'
source = require 'vinyl-source-stream'
watch = require 'gulp-watch'
sass = require 'gulp-sass'
rename = require 'gulp-rename'

keepWatching = true

gulp.task 'coffee', ->
  bundlerFunction = if keepWatching then watchify else watchify.browserify
  bundler = bundlerFunction entries: ['./app/coffee/app.coffee'], extensions: ['.coffee']
    .transform 'coffeeify'
    .transform 'browserify-shim'
    .transform 'uglifyify'

  rebundle = (ids) ->
    gutil.log if ids then "Rebundling because of change in #{ids}" else 'Bundling'
    bundler.bundle()
      .pipe source('script.js')
      .pipe gulp.dest('./build/')

  bundler.on('update', rebundle) if keepWatching
  rebundle()

gulp.task 'sass', ->
  gulp.src './app/scss/main.scss'
    .pipe if keepWatching then watch() else gutil.noop()
    .pipe sass(errLogToConsole: true)
    .pipe rename('style.css')
    .pipe gulp.dest('./build/')

gulp.task 'index', ->
  gulp.src './app/index.html'
    .pipe if keepWatching then watch() else gutil.noop()
    .pipe rename('index.html')
    .pipe gulp.dest('./build/')

gulp.task 'images', ->
  gulp.src './app/images/*'
    .pipe if keepWatching then watch() else gutil.noop()
    .pipe gulp.dest('./build/images/')
  
gulp.task 'default', ['coffee', 'sass', 'index', 'images']
