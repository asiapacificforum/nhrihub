class CreateOutcomesTable < ActiveRecord::Migration
  def change
    create_table :outcomes do |t|
      t.integer :planned_result_id
      t.text :description
      t.timestamps
    end
  end
end
