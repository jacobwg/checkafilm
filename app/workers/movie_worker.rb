class MovieWorker
  include Sidekiq::Worker
  def perform(movie_id)
    movie = Movie.find(movie_id)
    movie.load_information! if movie.added? or true # manually allowing reprocessing of movies
  end
end