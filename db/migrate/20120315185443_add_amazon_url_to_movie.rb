class AddAmazonUrlToMovie < ActiveRecord::Migration
  def change
    add_column :movies, :amazon_url, :string

  end
end
