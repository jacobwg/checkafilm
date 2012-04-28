require './config/boot'
require './config/environment'
require 'rubygems'
require 'clockwork'
include Clockwork

handler do |job|
  case job
  when :refresh
    Movie.find_each do |movie|
      movie.async_refresh_information
    end
  when :posters
    Movie.find_each do |movie|
      movie.async_refresh_posters
    end
  end
end

every(1.hour, :refresh)
every(1.day, :posters)