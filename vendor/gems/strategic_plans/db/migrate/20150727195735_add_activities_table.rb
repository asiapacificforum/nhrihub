class AddActivitiesTable < ActiveRecord::Migration[4.2]
  def change
    create_table :activities, :force => true do |t|
      t.integer :outcome_id
      t.text :description
      t.text :performance_indicator
      t.text :target
      t.timestamps
    end
  end
end
