App.Router.MoviesRouter = Backbone.Router.extend
  el: '#content'
  routes:
    'movies/:id' : 'show'
    '/': 'index'
  initialize: ->
    App.movies ||= new App.Collection.Movies
    App.movies.fetch()
  index: ->
    this.movieListView ||= new App.View.MovieListView(collection: App.movies)
    $(App.content).html(this.movieListView.render().el)
    console.log('movies#index')
  show: (id) ->
      if movie = App.movies.get(id)
        $(App.content).html(new App.View.MovieDetailView(model: movie).render().el)
        window.checkLoaded(movie.imdbid) if movie.added
        console.log('movies#show')
      else
        movie = new App.Model.Movie(imdbid: id, id: id)
        movie.fetch
          success: (data) ->
            $(App.content).html(new App.View.MovieDetailView(model: data).render().el)
            App.movies.add(data)
            window.checkLoaded(data.imdbid) if data.added
            console.log('movies#show')

App.moviesRouter = new App.Router.MoviesRouter