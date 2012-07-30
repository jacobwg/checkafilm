class AddNameToTrailers < ActiveRecord::Migration
  def change
    add_column :trailers, :name, :string
  end
end
