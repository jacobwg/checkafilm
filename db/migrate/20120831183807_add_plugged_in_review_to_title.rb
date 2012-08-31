class AddPluggedInReviewToTitle < ActiveRecord::Migration
  def change
    add_column :titles, :plugged_in_review, :text
  end
end
