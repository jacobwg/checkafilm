App.Router.MoviesRouter = Backbone.Router.extend
  routes:
    'movies/:id' : 'show'
    '': 'index'
  initialize: ->
    App.movies ||= new App.Collection.Movies
    App.movies.fetch()
  index: (params) ->
    this.movieListView ||= new App.View.MovieListView(collection: App.movies)
    $(App.content).html(this.movieListView.render().el)
  show: (id) ->
    if movie = App.movies.get(id)
      $(App.content).html(new App.View.MovieDetailView(model: movie).render().el)
      if movie.get('added')
        window.checkLoaded(movie.get('imdbid'))
    else
      movie = new App.Model.Movie(imdbid: id, id: id)
      movie.fetch
        success: (data) ->
          $(App.content).html(new App.View.MovieDetailView(model: data).render().el)
          App.movies.add(data) unless App.movies.get(data.imdbid)
          if movie.get('added')
            window.checkLoaded(movie.get('imdbid'))

App.moviesRouter = new App.Router.MoviesRouter