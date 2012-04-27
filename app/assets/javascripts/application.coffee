# jquery is loaded from Google
#= require jquery-ui
#= require jquery_ujs
#= require json2
#= require bootstrap
#= require webapp

window.preloadImage = (src) ->
  $('<img/>')[0].src = src

jQuery ($) ->

  $('#top-message').ajaxStart ->
    $(this).addClass "active"

  $('#top-message').ajaxStop ->
    $(this).removeClass "active"

  App.mobileOnly ->
    setTimeout ->
      window.scrollTo 0, 1
    , 1


window.searchTmdb = (query, callback) ->
 url = "http://api.themoviedb.org/2.1/Movie.search/en-US/json/" + App.tmdb_api_key + "/" + encodeURIComponent(query)
 $.getJSON "http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20json%20where%20url%3D'" + encodeURIComponent(url) + "'&format=json&callback=?", (data) ->
   if data.query.results.json.json
     callback data.query.results.json.json
   else
     callback []

window.searchImdb = (query, callback) ->
  url = "http://www.imdb.com/xml/find?json=1&nr=1&tt=on&q=" + encodeURIComponent(query)
  $.getJSON "http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20json%20where%20url%3D'" + encodeURIComponent(url) + "'&format=json&callback=?", (data) ->
    if data.query.results
      callback data.query.results.json
    else
      callback []

window.checkLoaded = (imdbid) ->
  $.getJSON "/title/" + imdbid, (data, status, xhr) ->
    if data.added
      window.checkTimeout = setTimeout("window.checkLoaded(\"" + data.imdbid + "\")", 1000)
    else
      clearTimeout window.checkTimeout if window.checkTimeout
      window.location.reload true
