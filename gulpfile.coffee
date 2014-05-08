gulp = require 'gulp'
browserify = require 'browserify'
coffeeify = require 'coffeeify'
source = require 'vinyl-source-stream'

gulp.task 'coffeeify', ->
  browserify({ entries: ['./app/app.coffee'], extensions: ['.coffee'] })
    .bundle()
    .pipe(source('bundle.js'))
    .pipe(gulp.dest('./build/'))

gulp.task 'default', ->
  console.log 'default task called'
