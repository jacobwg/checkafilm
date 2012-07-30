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
//= require jquery_ujs
//= require bootstrap
//= require jquery.backstretch
//= require jquery.fancybox
//= require jquery.fancybox-media

function poll() {
  $.getJSON(window.location, function(data) {
    if (data.status_state != 'fresh') {
      window.reload();
    } else {
      window.setTimeout(poll, 2000);
    }
  });
}

$(function() {
  $('.fancybox-media').fancybox({
    openEffect  : 'none',
    closeEffect : 'none',
    fitToView : true,
    helpers : {
      media : {}
    }
  });

  if (window.images == undefined)
    return;

  var images = window.images;

  // A little script for preloading all of the images
  // It"s not necessary, but generally a good idea
  $(images).each(function(){
    $("<img/>")[0].src = this;
  });

  // The index variable will keep track of which image is currently showing
  var index = 0;

  // Call backstretch for the first time,
  // In this case, I"m settings speed of 500ms for a fadeIn effect between images.
  $.backstretch(images[index], {speed: 500});

  // Set an interval that increments the index and sets the new image
  // Note: The fadeIn speed set above will be inherited
  setInterval(function() {
    index = (index >= images.length - 1) ? 0 : index + 1;
    $.backstretch(images[index]);
  }, 5000);
});