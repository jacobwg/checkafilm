class Trailer < ActiveRecord::Base

  include Mongoid::Document

  field :url, type: String
  field :name, type: String
  field :thumbnail, type: String

  embedded_in :title

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
    ThumbnailJob.create(id: self.id)
  end
end
