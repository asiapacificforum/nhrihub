class AddComplaintStatuses < ActiveRecord::Migration[5.0]
  def change
    create_table :complaint_statuses, :force => true do |t|
      t.string :name
      t.timestamps
    end

    remove_column :status_changes, :new_value, :boolean
    add_column :status_changes, :complaint_status_id, :integer
  end
end
