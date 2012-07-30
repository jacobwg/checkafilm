class AddThumbnailToTrailer < ActiveRecord::Migration
  def change
    add_column :trailers, :thumbnail, :string
  end
end
