class AddStrategicPlansTable < ActiveRecord::Migration
  def change
    create_table :strategic_plans do |t|
      t.date :start_date
      t.timestamps
    end
  end
end
