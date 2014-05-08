gulp = require 'gulp'
gutil = require 'gulp-util'
watchify = require 'watchify'
source = require 'vinyl-source-stream'
watch = require 'gulp-watch'
sass = require 'gulp-sass'
rename = require 'gulp-rename'

gulp.task 'coffee', ->
  bundler = watchify entries: ['./app/app.coffee'], extensions: ['.coffee']

  rebundle = (ids) ->
    gutil.log if ids then "Rebundling because of change in #{ids}" else 'Bundling'
    bundler.bundle()
      .pipe source('bundle.js')
      .pipe gulp.dest('./build/')

  bundler.on 'update', rebundle
  rebundle()

gulp.task 'sass', ->
  gulp.src './app/scss/main.scss'
    .pipe watch()
    .pipe sass(errLogToConsole: true)
    .pipe rename('stylesheet.css')
    .pipe gulp.dest('./build/')
  
gulp.task 'default', ['coffee', 'sass']
