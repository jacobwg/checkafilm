App.View.MovieListView = Backbone.View.extend
  template: window.JST['templates/movies/index']
  render: (eventName) ->
    $(this.el).html(this.template(movies: this.collection.toJSON()))
    this