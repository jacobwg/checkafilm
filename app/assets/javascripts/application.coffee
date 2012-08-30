#= require jquery
#= require jquery_ujs
#= require bootstrap
#= require jquery.fancybox
#= require jquery.fancybox-media
#= require docs

window.poll = () ->
  $.getJSON window.location, (data) ->
    if data.status_state is 'loaded'
      window.location = window.location
    else
      window.setTimeout window.poll, 2000

setImage = (div, image) ->
  $(div).css('background-image', "url(#{image})")

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

    setImage('#titlehead', window.images[index])
    setInterval () ->
      if index >= window.images.length - 1
        index = 0
      else
        index += 1
      setImage('#titlehead', window.images[index])
    , 5000

  setTimeout ->
    window.scrollTo 0, 1
  , 1
