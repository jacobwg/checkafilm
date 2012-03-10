App.View.MovieDetailView = Backbone.View.extend
    template: Handlebars.compile($("#movie-details").html())
    render: (eventName) ->
      $(this.el).html(this.template(sermon: this.model.toJSON()))
      this