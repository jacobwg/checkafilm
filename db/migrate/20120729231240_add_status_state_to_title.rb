class AddStatusStateToTitle < ActiveRecord::Migration
  def change
    add_column :titles, :status_state, :string
  end
end
