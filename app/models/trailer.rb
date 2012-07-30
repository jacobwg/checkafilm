class Trailer < ActiveRecord::Base
  attr_accessible :title_id, :url, :title, :name
  attr_accessible :thumbnail, :remote_thumbnail_url

  belongs_to :title, touch: true

  mount_uploader :thumbnail, TrailerThumbnailUploader

  def fetch_thumbnail!
    return unless self.url

    Rails.logger.info('Fetching thumbnail...')
    thumbnail_url = Youtube.get_thumbnail(self.url)
    if thumbnail_url and thumbnail_url != self.original_thumbnail_url
      self.remote_thumbnail_url = thumbnail_url
      self.original_thumbnail_url = thumbnail_url
      self.save
    end
    Rails.logger.info('Thumbnail fetched...')
  end

  def async_fetch_thumbnail!
    Resque.enqueue(ThumbnailJob, self.id)
  end
end
