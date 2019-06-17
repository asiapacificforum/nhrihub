class CreateOutcomesTable < ActiveRecord::Migration[4.2]
  def change
    create_table :outcomes, :force => true do |t|
      t.integer :planned_result_id
      t.text :description
      t.timestamps
    end
  end
end
