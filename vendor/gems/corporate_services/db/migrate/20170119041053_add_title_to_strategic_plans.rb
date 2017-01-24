class AddTitleToStrategicPlans < ActiveRecord::Migration[5.0]
  def change
    add_column :strategic_plans, :title, :string
  end
end
