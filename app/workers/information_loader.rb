class InformationLoader
  include Sidekiq::Worker
  def perform(movie_id, type)
    movie = Movie.find(movie_id)
    type = type.to_sym
    puts "Type is #{type}"
    case type
    when :all
      movie.load_all_information!
    when :refresh
      movie.refresh_information!
    when :posters
      movie.load_posters!
    end
  end
end