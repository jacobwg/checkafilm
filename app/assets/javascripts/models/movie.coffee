App.Model.Movie = Backbone.Model.extend
  idAttribute: "imdbid"
  defaults:
    status: 'added'
  url: ->
    return '/movies/' + this.get('imdbid')