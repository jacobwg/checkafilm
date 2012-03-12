App.View.MovieDetailView = Backbone.View.extend
  template: JST['templates/movies/show']
  render: (eventName) ->
    $(this.el).html(this.template(movie: this.model.toJSON()))
    if this.model.get('backdrop_url')
      $('html').css
        'background': 'url(' + this.model.get('backdrop_url') + ') no-repeat center center fixed'
        '-ms-filter': '"progid:DXImageTransform.Microsoft.AlphaImageLoader(src=\'' + this.model.get('backdrop_url') + '\', sizingMethod=\'scale\')"'
        'filter': 'progid:DXImageTransform.Microsoft.AlphaImageLoader(src=\'' + this.model.get('backdrop_url') + '\', sizingMethod=\'scale\')'
    this