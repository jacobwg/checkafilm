class AddHomepageToTitle < ActiveRecord::Migration
  def change
    add_column :titles, :homepage, :string
  end
end
