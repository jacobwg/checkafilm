class AddRottenTomatoesLinkToTitle < ActiveRecord::Migration
  def change
    add_column :titles, :rotten_tomatoes_link, :string
  end
end
