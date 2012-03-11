App.View.MovieDetailView = Backbone.View.extend
  template: JST['templates/movies/show']
  render: (eventName) ->
    $(this.el).html(this.template(movie: this.model.toJSON()))
    this