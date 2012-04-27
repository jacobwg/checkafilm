require './config/boot'
require './config/environment'
require 'rubygems'
require 'clockwork'
include Clockwork

handler do |job|
  Movie.find_each do |movie|
    movie.async_load_information
  end
end

every(1.hour, 'refresh')