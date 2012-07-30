class ThumbnailJob
  extend Resque::Plugins::LockTimeout

  @queue = :trailers
  @lock_timeout = 600 # five minutes

  def self.perform(trailer_id)
    trailer = Trailer.find(trailer_id)
    trailer.fetch_thumbnail! if trailer
  end
end
