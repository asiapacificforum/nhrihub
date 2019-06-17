class AddPlannedResultsTable < ActiveRecord::Migration[4.2]
  def change
    create_table :planned_results, :force => true do |t|
      t.string :description
      t.integer :strategic_priority_id
      t.timestamps
    end
  end
end
