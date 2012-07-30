class AddRuntimeToTitle < ActiveRecord::Migration
  def change
    add_column :titles, :runtime, :string
  end
end
