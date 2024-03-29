moment = require 'moment'

module.exports = docpadConfig = {

  templateData:

    site:
      url: "http://professorp.co.uk"
      oldUrls: ['www.professorp.co.uk']
      title: "Professor P's Website"
      description: """
        Website for the Professor P series of children's books
        """
      styles: [
        '//netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css'
        #'//netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap-theme.min.css'
        '/style.css'
      ]
      scripts: [
        '//ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js'
        '//netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js'
        '//cdnjs.cloudflare.com/ajax/libs/bootstrap-hover-dropdown/2.0.2/bootstrap-hover-dropdown.min.js'
      ]

    # Helper Functions
    getPreparedTitle: ->
      if @document.title
        "#{@document.title} | #{@site.title}"
      else
        @site.title

    getPreparedDescription: ->
      @document.description or @site.description

    formatDate: (date, format='DD MMMM YYYY') ->
      moment(date).format(format)


  # Speed up file watching
  regenerateDelay: 10
  watchOptions: catchupDelay: 0


  # Don't include high-res images
  ignoreCustomPatterns: /.*high-res.jpg/


  collections:
    books: ->
      @getCollection('documents').findAllLive({collection: 'books'}, [filename: 1])

    games: ->
      @getCollection('documents').findAllLive({collection: 'games'}, [filename: 1])

    activities: ->
      @getCollection('documents').findAllLive({collection: 'activities'}, [filename: 1])

    individualEvents: ->
      @getCollection('documents').findAllLive({collection: 'events'}, [filename: 1])


  # DocPad's default environment is the production environment
  # The development environment, actually extends from the production environment

  # The following overrides our production url in our development environment with false
  # This allows DocPad's to use it's own calculated site URL instead, due to the falsey value
  # This allows <%- @site.url %> in our template data to work correctly, regardless what environment we are in

  environments:
    development:
      templateData:
        site:
          url: false

  plugins:

    cleanurls:
      static: true
      trailingSlashes: true
    
    htmlmin:
      removeComments: true
      removeCommentsFromCDATA: false
      removeCDATASectionsFromCDATA: false
      collapseWhitespace: true
      collapseBooleanAttributes: false
      removeAttributeQuotes: false
      removeRedundantAttributes: false
      useShortDoctype: false
      removeEmptyAttributes: false
      removeOptionalTags: false
      removeEmptyElements: false

      environments:
        development:
          enabled: false

    sass:
      scssPath: 'node-sass'

  events:

    # Server Extend
    # Used to add our own custom routes to the server before the docpad routes are added
    serverExtend: (opts) ->
      # Extract the server from the options
      {server} = opts
      docpad = @docpad

      # As we are now running in an event,
      # ensure we are using the latest copy of the docpad configuraiton
      # and fetch our urls from it
      latestConfig = docpad.getConfig()
      oldUrls = latestConfig.templateData.site.oldUrls or []
      newUrl = latestConfig.templateData.site.url

      # Redirect any requests accessing one of our sites oldUrls to the new site url
      server.use (req,res,next) ->
        if req.headers.host in oldUrls
          res.redirect(newUrl+req.url, 301)
        else
          next()
}
