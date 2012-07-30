class AddOriginalThumbnailUrlToTrailer < ActiveRecord::Migration
  def change
    add_column :trailers, :original_thumbnail_url, :string
  end
end
