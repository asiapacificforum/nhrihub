class AddPlannedResultsTable < ActiveRecord::Migration
  def change
    create_table :planned_results do |t|
      t.string :description
      t.integer :strategic_priority_id
      t.timestamps
    end
  end
end
