class AddStrategicPrioritiesTable < ActiveRecord::Migration
  def change
    create_table :strategic_priorities do |t|
      t.integer :priority_level
      t.text :description
      t.integer :strategic_plan_id
      t.timestamps
    end
  end
end
