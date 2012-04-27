class RefreshWorker
  include Sidekiq::Worker
  def perform(movie_id)
    movie = Movie.find(movie_id)
    movie.load_information!
  end
end