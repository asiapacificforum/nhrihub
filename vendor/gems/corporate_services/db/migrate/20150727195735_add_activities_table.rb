class AddActivitiesTable < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.integer :outcome_id
      t.text :description
      t.text :performance_indicator
      t.text :target
      t.timestamps
    end
  end
end
