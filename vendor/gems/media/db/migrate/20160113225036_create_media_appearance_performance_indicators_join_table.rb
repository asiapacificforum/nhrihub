class CreateMediaAppearancePerformanceIndicatorsJoinTable < ActiveRecord::Migration[4.2]
  def change
    create_table :media_appearance_performance_indicators, :force => true do |t|
      t.integer :media_appearance_id
      t.integer :performance_indicator_id
      t.timestamps
    end
  end
end
