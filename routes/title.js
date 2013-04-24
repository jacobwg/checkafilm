var tmdb = require('../lib/tmdb');

exports.show = function(req, res) {
  tmdb.fetchTitle(req.params.imdbid, function(data){
    res.render('title', data);
  });
};