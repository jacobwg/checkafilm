class AddStatusToMovie < ActiveRecord::Migration
  def change
    add_column :movies, :status, :string, default: 'added'
    add_index :movies, :status

  end
end
