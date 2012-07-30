class AddSlugToTitle < ActiveRecord::Migration
  def change
    add_column :titles, :slug, :string
    add_index :titles, :slug, unique: true
  end
end
