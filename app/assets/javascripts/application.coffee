#= require jquery
#= require jquery_ujs
#= require bootstrap
#= require jquery.backstretch
#= require jquery.fancybox
#= require jquery.fancybox-media

window.poll = () ->
  $.getJSON window.location, (data) ->
    if data.status_state is 'loaded'
      window.location = window.location
    else
      window.setTimeout window.poll, 2000

jQuery ($) ->
  $('.fancybox-media').fancybox
    openEffect: 'none'
    closeEffect: 'none'
    fitToView: true
    helpers:
      media: {}

  if window.images
    for image in window.images
      $('<img/>')[0].src = image

    index = 0

    $.backstretch window.images[index], speed: 500

    setInterval () ->
      if index >= window.images.length - 1
        index = 0
      else
        index += 1
      $.backstretch(window.images[index])
    , 5000

  setTimeout ->
    window.scrollTo 0, 1
  , 1
