var tmdb = require('../lib/tmdb');
var moment = require('moment');

exports.show = function(req, res) {
  tmdb.fetchTitle(req.params.imdbid, function(data){
    data.json = JSON.stringify(data);
    data.release_date = moment(data.release_date);
    res.render('title', data);
  });
};

exports.search = function(req, res) {
  tmdb.search(req.query.q, function(data){
    data.title = "Search Results";
    console.log(data);
    res.render('search', data);
  });
};