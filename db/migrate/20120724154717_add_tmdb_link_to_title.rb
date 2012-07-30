class AddTmdbLinkToTitle < ActiveRecord::Migration
  def change
    add_column :titles, :tmdb_link, :string
  end
end
