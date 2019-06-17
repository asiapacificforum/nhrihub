class RemoveTextFromImpactRatingsTable < ActiveRecord::Migration[4.2]
  def change
    remove_column :impact_ratings, :text
  end
end
