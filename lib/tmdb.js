var nconf = require('nconf');
nconf.argv().env().file({file: 'config.json'});

var Firebase = require('firebase');
var crypto = require('crypto');
var moment = require('moment');

var md5 = crypto.createHash('md5');

var mdb = require('moviedb')(nconf.get('TMDB_KEY'));

var db = new Firebase('https://checkafilm.firebaseio.com');

var cache = function(namespace, id, callback, fetcher) {
  var child = db.child(namespace).child(id);
  child.once('value', function(snap) {
    // cache time of one minute
    if (snap.val() && (snap.val().cache_time > (moment().unix() - 60 * 60 * 24))) {
      callback(snap.val());
    } else {
      fetcher(function(data) {
        data.cache_time = moment().unix();
        child.set(data);
        callback(data);
      });
    }
  });
};

module.exports = {
  fetchTitle: function(id, callback) {
    cache('title', id, callback, function(fetcher) {
      mdb.movieInfo({id: id, append_to_response:'images,casts,trailers'}, function(err, data){
        fetcher(data);
      });
    });
  },
  search: function(query, callback) {
    cache('search', crypto.createHash('md5').update(query).digest('hex'), callback, function(fetcher) {
      mdb.searchMovie({query: query}, function(err, data){
        fetcher(data);
      });
    });
  },
  nowPlaying: function(callback) {
    cache('nowPlaying', '0', callback, function(fetcher) {
      mdb.miscNowPlayingMovies(function(err, data) {
        fetcher(data);
      });
    });
  },
  upcoming: function(callback) {
    cache('upcoming', '0', callback, function(fetcher) {
      mdb.miscUpcomingMovies({language: 'en', page: 3}, function(err, data) {
        fetcher(data);
      });
    });
  }
};