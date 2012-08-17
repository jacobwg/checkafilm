class ThumbnailJob
  include Resque::Plugins::UniqueJob

  @queue = :trailers

  def self.perform(trailer_id)
    trailer = Trailer.find(trailer_id)
    trailer.fetch_thumbnail! if trailer
  end
end
