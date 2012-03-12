App.View.MovieListView = Backbone.View.extend
  template: JST['templates/movies/index']
  render: (eventName) ->
    $(this.el).html(this.template(movies: this.collection.toJSON()))
    $('html').css
      'background': 'url(/assets/backdrop.jpg) no-repeat center center fixed'
      '-ms-filter': '"progid:DXImageTransform.Microsoft.AlphaImageLoader(src=\'/assets/backdrop.jpg\', sizingMethod=\'scale\')"'
      'filter': 'progid:DXImageTransform.Microsoft.AlphaImageLoader(src=\'/assets/backdrop.jpg\', sizingMethod=\'scale\')'
    setTimeout ->
      window.scrollTo 0, 1
    , 1
    this