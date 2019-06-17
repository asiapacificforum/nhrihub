class AddStrategicPrioritiesTable < ActiveRecord::Migration[4.2]
  def change
    create_table :strategic_priorities, :force => true do |t|
      t.integer :priority_level
      t.text :description
      t.integer :strategic_plan_id
      t.timestamps
    end
  end
end
