//= require jquery
//= require jquery_ui
//= require jquery_ujs
//= require_tree .

window.Movie = Backbone.Model.extend({
  idAttribute: "imdbid",
  defaults: {
    'status': 'added'
  },
  url: function() {
    return 'movies/' + this.get('imdbid');
  },
  toJSON: function() {
    this.set('added', (this.get('status') == 'added'));
    this.set('not_added', (this.get('status') != 'added'));
    return this.attributes;
  }
});

window.MovieCollection = Backbone.Collection.extend({
	model: Movie,
	url: "movies"
});

var Movies = new MovieCollection();

window.MovieListView = Backbone.View.extend({
  el: $('#content'),
  initialize: function() {
    this.model.bind("reset", this.render, this);
  },
  template: Handlebars.compile($("#movie-list").html()),
  render: function(eventName) {
    $(this.el).html(this.template({movies: this.model.toJSON()}));
    return this;
  }
});

window.MovieView = Backbone.View.extend({
    el: $('#content'),
    template: Handlebars.compile($("#movie-details").html()),
    render: function(eventName) {
      $(this.el).html(this.template(this.model.toJSON()));
      return this;
    }
});

var AppRouter = Backbone.Router.extend({
  routes: {
    "" : "index",
    "movies/:id" : "movie"
  },
  index: function() {
    this.movieListView = new MovieListView({model: window.Movies});
    this.movieListView.render();
  },

  movie: function(id) {
    this.movie = window.Movies.get(id);
    if (this.movie === undefined) {
      this.movie = new Movie();
      this.movie.id = id;
      this.movie.set('imdbid', id);
      this.movie.fetch({success: function(data) {
        Movies.add(this);
      }});
      window.checkLoaded(id);
      //this.movie = window.Movies.
    }
    this.movieView = new MovieView({model: this.movie});
    this.movieView.render();
  }
});

window.checkLoaded = function(imdbid) {
  $.getJSON('movies/' + imdbid, function(data, status, xhr) {
    if (data.status == 'added'){
      window.checkTimeout = setTimeout('window.checkLoaded("' + imdbid + '")', 1000);
    } else {
      if (window.checkTimeout) clearTimeout(window.checkTimeout);
      window.location.reload(true);
      window.app.navigate('movies/' + imdbid, {trigger: true});
    }
  });
};



function searchImdb(query, callback) {
  var url = "http://www.imdb.com/xml/find?json=1&nr=1&tt=on&q=" + encodeURIComponent(query);
  return $.getJSON("http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20json%20where%20url%3D'" + encodeURIComponent(url) + "'&format=json&diagnostics=true&callback=?",
  function(data){
    console.info(data)
    if (data.query.results) {
      callback(data.query.results.json);
    } else {
      callback([]);
    }
  });
}



$(function() {



  window.app = new AppRouter();
  Backbone.history.start({pushState: true});

  $(document).on('click', 'a', function (e) {
      app.navigate($(this).attr('href'), true);
      return false;
  });
  $(window).on('popstate', function(e) {
      app.navigate(location.pathname.substr(1), true);
  });

  var cache = function($) {
    var my = {};
    var data = {};

    if (Box.supported()) {
      my.has = function(key) {
        return Box.isset(key);
      };
      my.get = function(key){
        return Box.fetch(key);
      };
      my.set = function(key, value){
        Box.store(key, value);
      };
    } else {
      my.has = function(key) {
        return (key in data);
      };
      my.get = function(key){
        return data[key];
      };
      my.set = function(key, value){
        data[key] = value;
      };
    }




    return my;
  }($);


  var lastXhr;

  $('#searchform').on('submit', function() {
    var query = $('#moviesearch').val();

    var movie;

    if (cache.has(query)) {
      var data = cache.get(query);
      if (data.length > 0) {
        window.app.navigate('movies/' + data.imdb_id, {trigger: true});
      }
    } else {
      $.getJSON('/search', {term: query}, function(data, status, xhr) {
        if (data.length > 0) {
          window.app.navigate('movies/' + data[0].imdb_id, {trigger: true});
        }
      });
    }
    return false;
  });

  $('#moviesearch').ajaxStart(function() {
    $('#moviesearch').addClass('loading');
  });

  $('#moviesearch').ajaxStop(function() {
    $('#moviesearch').removeClass('loading');
  });

  $('#moviesearch').autocomplete({
    minLength: 2,
    focus: function(event, ui) {
      $('#moviesearch').val(ui.item.name);
      return false;
    },
    select: function(event, ui) {
      window.app.navigate('movies/' + ui.item.imdb_id, {trigger: true});
    },
    source: function(request, response) {
      var query = request.term;
      if (cache.has(query)) {
        response(cache.get(query));
        return;
      }

      lastXhr = $.getJSON("/search", request, function(data, status, xhr) {
        cache.set(query, data);
        if (xhr == lastXhr) {
          response(data);
        }
      })
    }
  }).data( "autocomplete" )._renderItem = function( ul, item ) {
    var el = $( "<li></li>" ).data( "item.autocomplete", item );
    if (item.posters[0]) {
      el = el.append( "<img src='" + item.posters[0].image.url + "' width='40' class='autocomplete pull-left' />");
    }
    el = el.append("<a>" + item.name + "<br>" + item.released + "</a>" ).appendTo( ul );
    return el;
  };
});