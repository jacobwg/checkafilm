# jquery is loaded from Google
#= require jquery-ui
#= require jquery_ujs
#= require json2
#= require underscore
#= require backbone
#= require handlebars
#= require bootstrap
#= require webapp

#= require app

#= require_tree ./models
#= require_tree ./collections
#= require_tree ./templates
#= require_tree ./views
#= require_tree ./routers

window.preloadImage = (src) ->
  $('<img/>')[0].src = src

jQuery ($) ->

  $( "#moviesearch" ).autocomplete
    minLength: 1,
    source: (request, response) ->
      url = "http://api.themoviedb.org/2.1/Movie.search/en-US/json/" + App.tmdb_api_key + "/" + encodeURIComponent(request.term)
      try
        window.searchRequest.abort() if window.searchRequest
      window.searchRequest = $.getJSON "http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20json%20where%20url%3D'" + encodeURIComponent(url) + "'&format=json&diagnostics=true&callback=?", (data) ->
        $('#top-message').removeClass "active"
        if data.query.results.json.json
          response data.query.results.json.json.slice(0, 10)
        else
          response []
      $('#top-message').addClass "active"
    focus: (event, ui) ->
      $( "#moviesearch" ).val( ui.item.label )
      false
    select: (event, ui) ->
      App.navigate('movies/' + ui.item.imdb_id, trigger: true)
      false
  .data( "autocomplete" )._renderItem = (ul, item) ->
    el = $( "<li></li>" ).data( "item.autocomplete", item )
    link = $('<a></a>').html(item.name + "<br>" + (new Date(Date.parse(item.released))).getFullYear())
    img = $("<img width='40' class='autocomplete pull-left' />")
    img.attr('src', item.posters[0].image.url) if item.posters
    img.prependTo(link)
    el.append(link)
    el.appendTo(ul)

  $('#top-message').ajaxStart ->
    $(this).addClass "active"

  $('#top-message').ajaxStop ->
    $(this).removeClass "active"


window.searchTmdb = (query, callback) ->
 url = "http://api.themoviedb.org/2.1/Movie.search/en-US/json/" + App.tmdb_api_key + "/" + encodeURIComponent(query)
 $.getJSON "http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20json%20where%20url%3D'" + encodeURIComponent(url) + "'&format=json&diagnostics=true&callback=?", (data) ->
   if data.query.results.json.json
     callback data.query.results.json.json
   else
     callback []

window.searchImdb = (query, callback) ->
  url = "http://www.imdb.com/xml/find?json=1&nr=1&tt=on&q=" + encodeURIComponent(query)
  $.getJSON "http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20json%20where%20url%3D'" + encodeURIComponent(url) + "'&format=json&diagnostics=true&callback=?", (data) ->
    if data.query.results
      callback data.query.results.json
    else
      callback []

window.checkLoaded = (imdbid) ->
  $.getJSON "/movies/" + imdbid, (data, status, xhr) ->
    if data.added
      window.checkTimeout = setTimeout("window.checkLoaded(\"" + data.imdbid + "\")", 1000)
    else
      clearTimeout window.checkTimeout if window.checkTimeout
      window.location.reload true


mobileOnly = (func) ->
  ua = navigator.userAgent
  func() if /Android/i.test( ua ) or /iP[ao]d|iPhone/i.test( ua ) or /Mobile/i.test( ua )

$ ->
  Backbone.history.start pushState: true
  $(document).on 'click', 'a[data-navigate]', (e) ->
    window.App.navigate($(this).attr('data-navigate'), trigger: true)
    false
  mobileOnly ->
    setTimeout ->
      window.scrollTo 0, 1
    , 1


###
  cache = ($) ->
    my = {}
    data = {}
    if Box.supported()
      my.has = (key) ->
        Box.isset key

      my.get = (key) ->
        Box.fetch key

      my.set = (key, value) ->
        Box.store key, value
    else
      my.has = (key) ->
        key of data

      my.get = (key) ->
        data[key]

      my.set = (key, value) ->
        data[key] = value
    my
  ($)
  lastXhr = undefined
  $("#searchform").on "submit", ->
    query = $("#moviesearch").val()
    movie = undefined
    if cache.has(query)
      data = cache.get(query)
      if data.length > 0
        window.app.navigate "movies/" + data.imdb_id,
          trigger: true
    else
      $.getJSON "/search",
        term: query
      , (data, status, xhr) ->
        if data.length > 0
          window.app.navigate "movies/" + data[0].imdb_id,
            trigger: true
    false

  $("#moviesearch").ajaxStart ->
    $("#moviesearch").addClass "loading"

  $("#moviesearch").ajaxStop ->
    $("#moviesearch").removeClass "loading"
###


###
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
###