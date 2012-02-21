class LoadMovieInformationJob
  include Resque::Plugins::UniqueJob
  @queue = :movies

  def self.perform(movie_id)
    movie = Movie.find(movie_id)
    movie.load_information!
  end
end