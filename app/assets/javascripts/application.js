// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ui
//= require jquery_ujs
//= require_tree .

$(function() {
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
        window.location = '/movies/' + data.imdb_id;
      }
    } else {
      $.getJSON('/search', {term: query}, function(data, status, xhr) {
        if (data.length > 0) {
          window.location = '/movies/' + data[0].imdb_id;
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
      window.location = '/movies/' + ui.item.imdb_id;
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
    return $( "<li></li>" )
    .data( "item.autocomplete", item )
    .append( "<img src='" + item.posters[0].image.url + "' width='40' class='autocomplete pull-left' />" + "<a>" + item.name + "<br>" + item.released + "</a>" )
    .appendTo( ul );
  };
});