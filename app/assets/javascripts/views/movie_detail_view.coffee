App.View.MovieDetailView = Backbone.View.extend
  template: JST['templates/movies/show']
  render: (eventName) ->
    document.title = this.model.get('title') + " (" + this.model.get('year') + ") | Check a Film"
    $(this.el).html(this.template(movie: this.model.toJSON()))
    photo = if App.isMobile() and not App.isIPad() then this.model.get('poster_url') else this.model.get('backdrop_url')
    if photo
      $('html').css
        'background': 'url(' + photo + ') no-repeat center center fixed'
        '-ms-filter': '"progid:DXImageTransform.Microsoft.AlphaImageLoader(src=\'' + photo + '\', sizingMethod=\'scale\')"'
        'filter': 'progid:DXImageTransform.Microsoft.AlphaImageLoader(src=\'' + photo + '\', sizingMethod=\'scale\')'
    setTimeout ->
      window.scrollTo 0, 1
    , 1
    this