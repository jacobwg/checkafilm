class MovieWorker
  include Sidekiq::Worker
  def perform(movie_id)
    movie = Movie.find(movie_id)
    movie.load_information! if movie.added?
  end
end