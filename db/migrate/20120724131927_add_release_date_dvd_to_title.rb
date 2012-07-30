class AddReleaseDateDvdToTitle < ActiveRecord::Migration
  def change
    add_column :titles, :release_date_dvd, :date
  end
end
