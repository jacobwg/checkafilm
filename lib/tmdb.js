var config = require('../config');
var moment = require('moment');
var mdb = require('moviedb')(config.api_key);

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