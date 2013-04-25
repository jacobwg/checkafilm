var nconf = require('nconf');
nconf.argv().env().file({file: 'config.json'});

var moment = require('moment');
var mdb = require('moviedb')(nconf.get('TMDB_KEY'));

module.exports = {
  fetchTitle: function(id, callback) {
    mdb.movieInfo({id: id, append_to_response:'images,casts,trailers'}, function(err, data){
      data.release_date = moment(data.release_date);
      callback(data);
    });
  },
  search: function(query, callback) {
    mdb.searchMovie({query: query}, function(err, data){
      callback(data);
    });
  }
};