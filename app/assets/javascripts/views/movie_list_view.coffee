App.View.MovieListView = Backbone.View.extend
  initialize: ->
    this.collection.bind("reset", this.render, this)
  template: window.JST['templates/movies/index']
  render: (eventName) ->
    $(this.el).html(this.template(movies: this.collection.toJSON()))
    this