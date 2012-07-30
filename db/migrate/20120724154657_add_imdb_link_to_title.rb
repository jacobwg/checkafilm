class AddImdbLinkToTitle < ActiveRecord::Migration
  def change
    add_column :titles, :imdb_link, :string
  end
end
