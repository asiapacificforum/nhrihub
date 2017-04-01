class DropImpactRatingsTable < ActiveRecord::Migration[5.0]
  def change
    drop_table :impact_ratings
  end
end
