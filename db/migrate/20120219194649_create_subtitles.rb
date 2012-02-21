class CreateSubtitles < ActiveRecord::Migration
  def change
    create_table :subtitles do |t|
      t.integer :start_time
      t.integer :end_time
      t.text :text
      t.text :cleaned_text
      t.integer :movie_id

      t.timestamps
    end

    add_index :subtitles, :movie_id
  end
end
