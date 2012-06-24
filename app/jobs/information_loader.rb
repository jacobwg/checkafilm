class InformationLoader
  @queue = :movies

  def self.perform(movie_id, type)
    movie = Movie.find(movie_id)
    puts "Type is #{type}"
    case type
    when 'all'
      movie.load_all_information!
    when 'refresh'
      movie.refresh_information!
    when 'posters'
      movie.load_posters!
    end
  end
end