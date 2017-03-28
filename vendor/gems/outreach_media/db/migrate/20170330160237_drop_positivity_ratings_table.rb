class DropPositivityRatingsTable < ActiveRecord::Migration[5.0]
  def change
    drop_table :positivity_ratings

    remove_column :media_appearances, :positivity_rating_id
  end
end
