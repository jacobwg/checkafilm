App.Collection.Movies = Backbone.Collection.extend
  model: App.Model.Movie
  url: "/title"