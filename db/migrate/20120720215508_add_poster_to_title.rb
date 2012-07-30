class AddPosterToTitle < ActiveRecord::Migration
  def change
    add_column :titles, :poster, :string
  end
end
