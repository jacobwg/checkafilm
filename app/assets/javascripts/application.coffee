#= require jquery
#= require jquery-ui
#= require jquery_ujs
#= require bootstrap
#= require webapp
#= require jquery.pjax

window.preloadImage = (src) ->
  $('<img/>')[0].src = src

jQuery ($) ->

  $('a:not([data-remote]):not([data-behavior]):not([data-skip-pjax])').pjax('[data-pjax-container]')
  $('[data-pjax-container]').on 'pjax:start', () ->
    clearTimeout window.checkTimeout if window.checkTimeout

  $('#top-message').ajaxStart ->
    $(this).addClass "active"

  $('#top-message').ajaxStop ->
    $(this).removeClass "active"

  setTimeout ->
    window.scrollTo 0, 1
  , 1

window.checkLoaded = (imdbid) ->
  $.getJSON "/title/" + imdbid, (data, status, xhr) ->
    if data.status isnt "added"
      clearTimeout window.checkTimeout if window.checkTimeout
      window.location = '/title/' + data.imdbid
    else
      window.checkTimeout = setTimeout("window.checkLoaded(\"" + data.imdbid + "\")", 1000)
