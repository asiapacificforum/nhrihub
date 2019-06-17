class AddStrategicPlansTable < ActiveRecord::Migration[4.2]
  def change
    create_table :strategic_plans, :force => true do |t|
      t.date :start_date
      t.timestamps
    end
  end
end
