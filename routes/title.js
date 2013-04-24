var tmdb = require('../lib/tmdb');

exports.show = function(req, res) {
  tmdb.fetchTitle(req.params.imdbid, function(data){
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