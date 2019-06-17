class CreateViolationSeverities < ActiveRecord::Migration[4.2]
  def change
    create_table :violation_severities, :force => true do |t|
      t.integer :rank
      t.string :text
      t.timestamps
    end
  end
end
