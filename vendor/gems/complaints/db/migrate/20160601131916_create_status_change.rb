class CreateStatusChange < ActiveRecord::Migration
  def change
    create_table :status_changes do |t|
      t.integer :complaint_id
      t.integer :user_id
      t.boolean :new_value, :default => true
      t.timestamps
    end
  end
end
