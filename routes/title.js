var config = require('../config');

var moment = require('moment');
var mdb = require('moviedb')(config.api_key);

mdb.configuration(function(err, res) {
  console.log(res);
});

exports.show = function(req, res) {
  mdb.movieInfo({id: req.params.imdbid, append_to_response:'images,casts,trailers'}, function(err, data){
    data.release_date = moment(data.release_date);
    res.render('title', data);
  });
};