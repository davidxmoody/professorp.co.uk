gulp = require 'gulp'
gutil = require 'gulp-util'
watchify = require 'watchify'
source = require 'vinyl-source-stream'

gulp.task 'coffee', ->
  bundler = watchify entries: ['./app/app.coffee'], extensions: ['.coffee']

  rebundle = (ids) ->
    gutil.log if ids then "Rebundling because of change in #{ids}" else 'Bundling'
    bundler.bundle()
      .pipe(source('bundle.js'))
      .pipe(gulp.dest('./build/'))

  bundler.on 'update', rebundle
  rebundle()
  
gulp.task 'default', ->
  console.log 'default task called'
