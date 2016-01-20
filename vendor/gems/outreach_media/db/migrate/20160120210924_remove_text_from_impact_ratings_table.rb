class RemoveTextFromImpactRatingsTable < ActiveRecord::Migration
  def change
    remove_column :impact_ratings, :text
  end
end
