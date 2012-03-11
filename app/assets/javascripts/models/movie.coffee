App.Model.Movie = Backbone.Model.extend
  initialize: ->
    this.bind 'change:poster_url change:backdrop_url', (event) ->
      window.preloadImage this.poster_url
    this.bind 'change:backdrop_url', (event) ->
      window.preloadImage this.backdrop_url
  idAttribute: "imdbid"
  defaults:
    status: 'added'
  url: ->
    return '/movies/' + this.get('imdbid')