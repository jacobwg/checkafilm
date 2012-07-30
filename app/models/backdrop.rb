class Backdrop < ActiveRecord::Base
  attr_accessible :image, :original_url, :title, :title_id, :remote_image_url, :image_url

  belongs_to :title, touch: true

  mount_uploader :image, BackdropUploader
end
