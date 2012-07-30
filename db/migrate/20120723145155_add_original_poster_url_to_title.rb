class AddOriginalPosterUrlToTitle < ActiveRecord::Migration
  def change
    add_column :titles, :original_poster_url, :string
  end
end
