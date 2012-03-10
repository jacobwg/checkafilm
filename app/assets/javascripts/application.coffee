#= require jquery
#= require jquery_ujs

#= require jquery.autocomplete

#= require bootstrap

#= require underscore
#= require backbone
#= require handlebars
#= require box

#= require app

#= require_tree ./models
#= require_tree ./collections
#= require_tree ./templates
#= require_tree ./views
#= require_tree ./routers

jQuery ($) ->
  $('#moviesearch').autocomplete
    serviceUrl: '/search'
    minChars: 2
    onSelect: (value, data) ->
      window.location = '/movies/' + data
  $("#moviesearch").ajaxStart ->
    $("#top-message").addClass "active"

  $("#moviesearch").ajaxStop ->
    $("#top-message").removeClass "active"
  #delimiter: /(,|;)\s*/, // regex or character
  #maxHeight:400,
  #width:300,
  #zIndex: 9999,
  #deferRequestBy: 0, //miliseconds
  #params: { country:'Yes' }, //aditional parameters
  #noCache: false, //default is false, set to true to disable caching
  #// callback function:
  #onSelect: function(value, data){ alert('You selected: ' + value + ', ' + data); },
  #// local autosugest options:
  #lookup: ['January', 'February', 'March', 'April', 'May'] //local lookup values


searchImdb = (query, callback) ->
  url = "http://www.imdb.com/xml/find?json=1&nr=1&tt=on&q=" + encodeURIComponent(query)
  $.getJSON "http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20json%20where%20url%3D'" + encodeURIComponent(url) + "'&format=json&diagnostics=true&callback=?", (data) ->
    console.info data
    if data.query.results
      callback data.query.results.json
    else
      callback []

window.checkLoaded = (imdbid) ->
  $.getJSON "/movies/" + imdbid, (data, status, xhr) ->
    if data.status is "added"
      window.checkTimeout = setTimeout("window.checkLoaded(\"" + imdbid + "\")", 1000)
    else
      clearTimeout window.checkTimeout if window.checkTimeout
      window.location.reload true
      window.app.navigate "movies/" + imdbid,
        trigger: true




###
$ ->
  Backbone.history.start pushState: true
  $(document).on "click", "a", (e) ->
    App.navigate $(this).attr("href"),
      trigger: true
    false
###


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